use serde::Serialize;
use wtx::{
  codec::i64_string,
  collection::{ArrayVectorU8, Vector},
  http::{
    Header, KnownHeaderName, ReqResBuffer, StatusCode,
    server_framework::{JsonReply, Router, ServerFrameworkBuilder, State, VerbatimParams, get},
  },
  misc::Wrapper,
  rng::{ChaCha20, CryptoSeedableRng},
  sync::Arc,
};

#[derive(Clone, wtx::ConnAux)]
struct ConnAux {
  dataset: Arc<Vector<DatasetItem>>,
}

#[tokio::main]
async fn main() -> wtx::Result<()> {  
  let dataset = load_dataset();
  let router = Router::paths(wtx::paths!(
    ("/baseline2", get(endpoint_baseline2)),
    ("/health", get(endpoint_health)),
    ("/json", get(endpoint_json)),
  ))?;
  ServerFrameworkBuilder::new(ChaCha20::from_std_random()?, router)
    .with_conn_aux(move |_| Ok(ConnAux { dataset: dataset.clone() }))
    .tokio(
      "0.0.0.0:8080",
      |error| eprintln!("{error:?}"),
      |_| Ok(()),
      |_| Ok(()),
      |error| eprintln!("{error:?}"),
    )
    .await
}

async fn endpoint_baseline2(
  state: State<'_, ConnAux, (), ReqResBuffer>,
) -> wtx::Result<VerbatimParams> {
  let query: BaselineQuery = serde_json::from_slice(&state.req.rrd.body)?;
  state.req.rrd.clear();
  let sum = query.a.unwrap_or(0).wrapping_add(query.b.unwrap_or(0));
  state.req.rrd.body.extend_from_copyable_slice(i64_string(sum).as_bytes())?;
  state
    .req
    .rrd
    .headers
    .push_from_iter(Header::from_name_and_value(KnownHeaderName::Server.into(), ["wtx"]))?;
  Ok(VerbatimParams(StatusCode::Ok))
}

async fn endpoint_health() {}

async fn endpoint_json(state: State<'_, ConnAux, (), ReqResBuffer>) -> wtx::Result<JsonReply> {
  let items = state.conn_aux.dataset.iter().map(|el| {
    Ok(ProcessedItem {
      id: el.id,
      name: &el.name,
      category: &el.category,
      price: el.price,
      quantity: el.quantity,
      active: el.active,
      tags: ArrayVectorU8::from_iterator(el.tags.iter().map(|el| el.as_str()))?,
      rating: RatingOut { score: el.rating.score, count: el.rating.count },
      total: (el.price * el.quantity as f64 * 100.0).round() / 100.0,
    })
  });
  let resp = JsonResponse { count: state.conn_aux.dataset.len(), items: Wrapper(items) };
  serde_json::to_writer(&mut state.req.rrd.body, &resp).unwrap_or_default();
  state
    .req
    .rrd
    .headers
    .push_from_iter(Header::from_name_and_value(KnownHeaderName::Server.into(), ["wtx"]))?;
  Ok(JsonReply(StatusCode::Ok))
}

fn load_dataset() -> Arc<Vector<DatasetItem>> {
  let path = std::env::var("DATASET_PATH").unwrap_or_else(|_| "/data/dataset.json".to_string());
  Arc::new(match std::fs::read_to_string(&path) {
    Ok(data) => serde_json::from_str(&data).unwrap_or_default(),
    Err(_) => Vector::new(),
  })
}

#[derive(serde::Deserialize)]
struct BaselineQuery {
  a: Option<i64>,
  b: Option<i64>,
}

#[derive(serde::Deserialize)]
struct DatasetItem {
  id: i64,
  name: String,
  category: String,
  price: f64,
  quantity: i64,
  active: bool,
  tags: ArrayVectorU8<String, 6>,
  rating: Rating,
}

#[derive(serde::Serialize)]
#[serde(bound = "E: Serialize")]
struct JsonResponse<E, I>
where
  I: Clone + Iterator<Item = wtx::Result<E>>,
  E: Serialize,
{
  items: Wrapper<I>,
  count: usize,
}

#[derive(serde::Serialize)]
struct ProcessedItem<'any> {
  id: i64,
  name: &'any str,
  category: &'any str,
  price: f64,
  quantity: i64,
  active: bool,
  tags: ArrayVectorU8<&'any str, 6>,
  rating: RatingOut,
  total: f64,
}

#[derive(serde::Deserialize)]
struct Rating {
  score: f64,
  count: i64,
}

#[derive(serde::Serialize)]
struct RatingOut {
  score: f64,
  count: i64,
}
