#[global_allocator]
static GLOBAL: mimalloc::MiMalloc = mimalloc::MiMalloc;

use may_minihttp::{HttpServer, HttpService, Request, Response};
use std::io::{self, Read};

#[derive(Clone)]
struct Server;

fn parse_query_params(path: &str) -> i64 {
    let query = match path.find('?') {
        Some(pos) => &path[pos + 1..],
        None => return 0,
    };
    let mut sum: i64 = 0;
    for pair in query.split('&') {
        if let Some(val) = pair.split('=').nth(1) {
            if let Ok(n) = val.parse::<i64>() {
                sum += n;
            }
        }
    }
    sum
}

impl HttpService for Server {
    fn call(&mut self, req: Request, rsp: &mut Response) -> io::Result<()> {
        let path = req.path();
        let route = match path.find('?') {
            Some(pos) => &path[..pos],
            None => path,
        };

        match route {
            "/baseline11" => {
                rsp.header("Content-Type: text/plain");
                let method = req.method();
                if method == "POST" {
                    let mut sum = parse_query_params(path);
                    let mut body = req.body();
                    let mut buf = Vec::new();
                    body.read_to_end(&mut buf)?;
                    if let Ok(s) = std::str::from_utf8(&buf) {
                        if let Ok(n) = s.trim().parse::<i64>() {
                            sum += n;
                        }
                    }
                    rsp.body_vec(sum.to_string().into_bytes());
                } else {
                    let sum = parse_query_params(path);
                    rsp.body_vec(sum.to_string().into_bytes());
                }
            }
            "/pipeline" => {
                rsp.header("Content-Type: text/plain");
                rsp.body("ok");
            }
            _ => {
                rsp.status_code(404, "Not Found");
                rsp.body("not found");
            }
        }
        Ok(())
    }
}

fn main() {
    may::config().set_workers(num_cpus::get());
    let server = HttpServer(Server).start("0.0.0.0:8080").unwrap();
    server.wait();
}
