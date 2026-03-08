
namespace RefundSystem.Core.Entities;

public class MonthlyBudget
{
    public int BudgetId { get; set; }
    public int BudgetYear { get; set; }
    public int BudgetMonth { get; set; }
    public decimal TotalBudget { get; set; }
    public decimal UsedBudget { get; set; }

    public decimal AvailableBudget => TotalBudget - UsedBudget;
}