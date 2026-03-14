use tonic::{transport::Server, Request, Response, Status};

pub mod benchmark {
    tonic::include_proto!("benchmark");
}

use benchmark::benchmark_service_server::{BenchmarkService, BenchmarkServiceServer};
use benchmark::{SumReply, SumRequest};

#[derive(Default)]
pub struct BenchmarkServiceImpl;

#[tonic::async_trait]
impl BenchmarkService for BenchmarkServiceImpl {
    async fn get_sum(
        &self,
        request: Request<SumRequest>,
    ) -> Result<Response<SumReply>, Status> {
        let req = request.into_inner();
        let reply = SumReply {
            result: req.a + req.b,
        };
        Ok(Response::new(reply))
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "0.0.0.0:8080".parse()?;
    let service = BenchmarkServiceImpl::default();

    println!("Application started.");

    Server::builder()
        .add_service(BenchmarkServiceServer::new(service))
        .serve(addr)
        .await?;

    Ok(())
}
