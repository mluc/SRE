# API Service

| Category     | SLI                                                                                                                | SLO                                                                                                         |
|--------------|--------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| Availability | # of successful request / total # of requests                                                                      | 99%                                                                                                         |
| Latency      | Bucket of requests in histogram showing the 90th percentile (over the last 5 minutes)  <br/> check if ^ is < 100ms | 90% of requests below 100ms                                                                                 |
| Error Budget | % error used = % error occurred / error budget = (1 - successful requests / total requests) / 0.2                  | Error budget is defined at 20%. This means that 20% of the requests can fail and still be within the budget |
| Throughput   | # of 2XX requests per second rate (over 5 minutes)                                                                 | 5 RPS indicates the application is functioning                                                              |
