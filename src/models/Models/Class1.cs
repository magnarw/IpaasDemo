namespace Models
{
    public class PurchaseOrder
    {
        public string OrderNumber { get; set; }
        public DateTime OrderDate { get; set; }
        public string BuyerName { get; set; }
        public string BuyerAddress { get; set; }
        public string SupplierName { get; set; }
        public string SupplierAddress { get; set; }
        public List<PurchaseOrderItem> Items { get; set; }
    }

    public class PurchaseOrderItem
    {
        public string ProductCode { get; set; }
        public string ProductName { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
    }
}