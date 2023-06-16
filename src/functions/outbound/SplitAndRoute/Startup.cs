using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


[assembly: FunctionsStartup(typeof(SplitAndRoute.Startup))]
namespace SplitAndRoute
{
 
    public class Startup : FunctionsStartup
    {

        public override void Configure(IFunctionsHostBuilder builder)
        {

            var serviceBusConnectionString = Environment.GetEnvironmentVariable("SERVICEBUS_ENDPOINT");
            if (string.IsNullOrEmpty(serviceBusConnectionString))
            {
                throw new InvalidOperationException(
                    "Please specify a valid ServiceBusConnectionString in the Azure Functions Settings or your local.settings.json file.");
            }

            //using AMQP as transport
            builder.Services.AddSingleton((s) => {
                return new ServiceBusClient(serviceBusConnectionString, new ServiceBusClientOptions() { TransportType = ServiceBusTransportType.AmqpTcp });
            });
      
        }
    }
}
