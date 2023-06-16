using System.Net;
using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace functions.SplitAndRoute
{
    public class PoSplitter
    {
        private readonly ILogger _logger;
        private readonly ServiceBusClient _client;

        public PoSplitter(ILoggerFactory loggerFactory, ServiceBusClient client)
        {
            _logger = loggerFactory.CreateLogger<PoSplitter>();
            _client = client;
        }

        [Function("SplitPo")]
        public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestData req)
        {
            _logger.LogInformation($"Recived PO-file");
            using var sr = new StreamReader(req.Body);

            string? line;

            var sender = _client.CreateSender("po-inbound" );

            while ((line = sr.ReadLine()) != null)
            {
                await sender.SendMessageAsync(new ServiceBusMessage(line));
            }
            var response = req.CreateResponse(HttpStatusCode.OK);
            _logger.LogInformation($"Processed PO-file");

            return response;
        }
    }
}
