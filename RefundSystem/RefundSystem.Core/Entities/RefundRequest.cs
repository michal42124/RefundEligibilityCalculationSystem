
namespace RefundSystem.Core.Entities;

public class RefundRequest
{
    public int RequestId { get; set; }
    public int CitizenId { get; set; }
    public int TaxYear { get; set; }
    public decimal ApprovedAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime RequestDate { get; set; }
    public decimal? CalculatedAmount { get; set; }
    public DateTime? ProcessedAt { get; set; }
    public string? ProcessedBy { get; set; }

    public Citizen Citizen { get; set; } = null!;
}
