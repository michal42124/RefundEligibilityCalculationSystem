USE [master]
GO
/****** Object:  Database [RefundEligibilityDB]    Script Date: 08/03/2026 07:56:11 ******/
CREATE DATABASE [RefundEligibilityDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'RefundEligibilityDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\RefundEligibilityDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'RefundEligibilityDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\RefundEligibilityDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [RefundEligibilityDB] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [RefundEligibilityDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [RefundEligibilityDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [RefundEligibilityDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [RefundEligibilityDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [RefundEligibilityDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [RefundEligibilityDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET RECOVERY FULL 
GO
ALTER DATABASE [RefundEligibilityDB] SET  MULTI_USER 
GO
ALTER DATABASE [RefundEligibilityDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [RefundEligibilityDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [RefundEligibilityDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [RefundEligibilityDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [RefundEligibilityDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [RefundEligibilityDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'RefundEligibilityDB', N'ON'
GO
ALTER DATABASE [RefundEligibilityDB] SET QUERY_STORE = OFF
GO
USE [RefundEligibilityDB]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CalculateTieredAmount]    Script Date: 08/03/2026 07:56:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_CalculateTieredAmount](@AverageIncome DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2) = 0;

    IF @AverageIncome > 9000 RETURN 0;

    IF @AverageIncome <= 5000
        RETURN ROUND(@AverageIncome * 0.15, 0);

    SET @Total = 5000 * 0.15;

    IF @AverageIncome <= 8000
        RETURN ROUND(@Total + (@AverageIncome - 5000) * 0.10, 0);

    SET @Total = @Total + 3000 * 0.10;
    SET @Total = @Total + (@AverageIncome - 8000) * 0.05;

    RETURN ROUND(@Total, 0);
END
GO
/****** Object:  Table [dbo].[Citizens]    Script Date: 08/03/2026 07:56:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Citizens](
	[CitizenId] [int] IDENTITY(1,1) NOT NULL,
	[IdNumber] [nvarchar](9) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CitizenId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[IdNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MonthlyBudgets]    Script Date: 08/03/2026 07:56:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MonthlyBudgets](
	[BudgetId] [int] IDENTITY(1,1) NOT NULL,
	[BudgetYear] [int] NOT NULL,
	[BudgetMonth] [int] NOT NULL,
	[TotalBudget] [decimal](12, 2) NOT NULL,
	[UsedBudget] [decimal](12, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[BudgetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_MonthlyBudgets_Year_Month] UNIQUE NONCLUSTERED 
(
	[BudgetYear] ASC,
	[BudgetMonth] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MonthlyIncomes]    Script Date: 08/03/2026 07:56:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MonthlyIncomes](
	[IncomeId] [int] IDENTITY(1,1) NOT NULL,
	[CitizenId] [int] NOT NULL,
	[TaxYear] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[IncomeAmount] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IncomeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_MonthlyIncomes_Citizen_Year_Month] UNIQUE NONCLUSTERED 
(
	[CitizenId] ASC,
	[TaxYear] ASC,
	[Month] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RefundRequests]    Script Date: 08/03/2026 07:56:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RefundRequests](
	[RequestId] [int] IDENTITY(1,1) NOT NULL,
	[CitizenId] [int] NOT NULL,
	[TaxYear] [int] NOT NULL,
	[ApprovedAmount] [decimal](10, 2) NULL,
	[Status] [nvarchar](20) NULL,
	[RequestDate] [datetime2](7) NULL,
	[CalculatedAmount] [decimal](10, 2) NULL,
	[ProcessedAt] [datetime2](7) NULL,
	[ProcessedBy] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[RequestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Citizens_IdNumber]    Script Date: 08/03/2026 07:56:11 ******/
CREATE NONCLUSTERED INDEX [IX_Citizens_IdNumber] ON [dbo].[Citizens]
(
	[IdNumber] ASC
)
INCLUDE([CitizenId],[FirstName],[LastName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_MonthlyBudgets_Year_Month]    Script Date: 08/03/2026 07:56:11 ******/
CREATE NONCLUSTERED INDEX [IX_MonthlyBudgets_Year_Month] ON [dbo].[MonthlyBudgets]
(
	[BudgetYear] ASC,
	[BudgetMonth] ASC
)
INCLUDE([TotalBudget],[UsedBudget]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_MonthlyIncomes_Citizen_TaxYear]    Script Date: 08/03/2026 07:56:11 ******/
CREATE NONCLUSTERED INDEX [IX_MonthlyIncomes_Citizen_TaxYear] ON [dbo].[MonthlyIncomes]
(
	[CitizenId] ASC,
	[TaxYear] ASC
)
INCLUDE([IncomeAmount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_MonthlyIncomes_CitizenId]    Script Date: 08/03/2026 07:56:11 ******/
CREATE NONCLUSTERED INDEX [IX_MonthlyIncomes_CitizenId] ON [dbo].[MonthlyIncomes]
(
	[CitizenId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_RefundRequests_CitizenId]    Script Date: 08/03/2026 07:56:11 ******/
CREATE NONCLUSTERED INDEX [IX_RefundRequests_CitizenId] ON [dbo].[RefundRequests]
(
	[CitizenId] ASC
)
INCLUDE([TaxYear],[ApprovedAmount],[Status],[RequestDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_RefundRequests_Status]    Script Date: 08/03/2026 07:56:11 ******/
CREATE NONCLUSTERED INDEX [IX_RefundRequests_Status] ON [dbo].[RefundRequests]
(
	[Status] ASC
)
WHERE ([Status] IN ('WaitingCalculation', 'WaitingApproval'))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MonthlyBudgets] ADD  DEFAULT ((0)) FOR [UsedBudget]
GO
ALTER TABLE [dbo].[RefundRequests] ADD  DEFAULT ((0)) FOR [ApprovedAmount]
GO
ALTER TABLE [dbo].[RefundRequests] ADD  DEFAULT ('WaitingCalculation') FOR [Status]
GO
ALTER TABLE [dbo].[RefundRequests] ADD  DEFAULT (getutcdate()) FOR [RequestDate]
GO
ALTER TABLE [dbo].[MonthlyIncomes]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyIncomes_Citizens] FOREIGN KEY([CitizenId])
REFERENCES [dbo].[Citizens] ([CitizenId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MonthlyIncomes] CHECK CONSTRAINT [FK_MonthlyIncomes_Citizens]
GO
ALTER TABLE [dbo].[RefundRequests]  WITH CHECK ADD  CONSTRAINT [FK_RefundRequests_Citizens] FOREIGN KEY([CitizenId])
REFERENCES [dbo].[Citizens] ([CitizenId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RefundRequests] CHECK CONSTRAINT [FK_RefundRequests_Citizens]
GO
ALTER TABLE [dbo].[Citizens]  WITH CHECK ADD  CONSTRAINT [CK_Citizens_FirstName_NotEmpty] CHECK  ((len(Trim([FirstName]))>(0)))
GO
ALTER TABLE [dbo].[Citizens] CHECK CONSTRAINT [CK_Citizens_FirstName_NotEmpty]
GO
ALTER TABLE [dbo].[Citizens]  WITH CHECK ADD  CONSTRAINT [CK_Citizens_IdNumber] CHECK  ((len([IdNumber])=(9) AND isnumeric([IdNumber])=(1)))
GO
ALTER TABLE [dbo].[Citizens] CHECK CONSTRAINT [CK_Citizens_IdNumber]
GO
ALTER TABLE [dbo].[Citizens]  WITH CHECK ADD  CONSTRAINT [CK_Citizens_LastName_NotEmpty] CHECK  ((len(Trim([LastName]))>(0)))
GO
ALTER TABLE [dbo].[Citizens] CHECK CONSTRAINT [CK_Citizens_LastName_NotEmpty]
GO
ALTER TABLE [dbo].[MonthlyBudgets]  WITH CHECK ADD CHECK  (([BudgetMonth]>=(1) AND [BudgetMonth]<=(12)))
GO
ALTER TABLE [dbo].[MonthlyBudgets]  WITH CHECK ADD CHECK  (([TotalBudget]>(0)))
GO
ALTER TABLE [dbo].[MonthlyBudgets]  WITH CHECK ADD CHECK  (([UsedBudget]>=(0)))
GO
ALTER TABLE [dbo].[MonthlyIncomes]  WITH CHECK ADD CHECK  (([IncomeAmount]>=(0)))
GO
ALTER TABLE [dbo].[MonthlyIncomes]  WITH CHECK ADD CHECK  (([Month]>=(1) AND [Month]<=(12)))
GO
ALTER TABLE [dbo].[RefundRequests]  WITH CHECK ADD CHECK  (([ApprovedAmount]>=(0)))
GO
ALTER TABLE [dbo].[RefundRequests]  WITH CHECK ADD  CONSTRAINT [CK_RefundRequests_Status] CHECK  (([Status]='Paid' OR [Status]='Rejected' OR [Status]='Approved' OR [Status]='WaitingApproval' OR [Status]='WaitingCalculation'))
GO
ALTER TABLE [dbo].[RefundRequests] CHECK CONSTRAINT [CK_RefundRequests_Status]
GO
/****** Object:  StoredProcedure [dbo].[sp_AllocateBudgetAtomically]    Script Date: 08/03/2026 07:56:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_AllocateBudgetAtomically]
    @BudgetYear   INT,
    @BudgetMonth  INT,
    @Amount       DECIMAL(10,2),
    @Success      BIT           OUTPUT,
    @Message      NVARCHAR(500) OUTPUT,
    @Remaining    DECIMAL(12,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @Success   = 0;
    SET @Message   = '';
    SET @Remaining = 0;

    DECLARE @TotalBudget DECIMAL(12,2);
    DECLARE @UsedBudget  DECIMAL(12,2);
    DECLARE @Available   DECIMAL(12,2);

    SELECT 
        @TotalBudget = TotalBudget,
        @UsedBudget  = UsedBudget
    FROM MonthlyBudgets WITH (UPDLOCK, HOLDLOCK)
    WHERE BudgetYear = @BudgetYear AND BudgetMonth = @BudgetMonth;

    IF @TotalBudget IS NULL
    BEGIN
        SET @Success = 0;
        SET @Message = N'תקציב לא קיים עבור ' + CAST(@BudgetMonth AS NVARCHAR) + '/' + CAST(@BudgetYear AS NVARCHAR);
        RETURN;
    END

    SET @Available = @TotalBudget - @UsedBudget;

    IF @Amount > @Available
    BEGIN
        SET @Success   = 0;
        SET @Message   = N'אין מספיק תקציב זמין. נדרש: ₪' + CAST(@Amount AS NVARCHAR) + N' זמין: ₪' + CAST(@Available AS NVARCHAR);
        SET @Remaining = @Available;
        RETURN;
    END

    UPDATE MonthlyBudgets
    SET UsedBudget = UsedBudget + @Amount
    WHERE BudgetYear = @BudgetYear AND BudgetMonth = @BudgetMonth;

    SET @Remaining = @Available - @Amount;
    SET @Success   = 1;
    SET @Message   = N'הוקצה בהצלחה';
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ApproveRequest]    Script Date: 08/03/2026 07:56:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ApproveRequest]
    @RequestId       INT,
    @IsApproved      BIT,
    @ProcessedBy     NVARCHAR(100),
    @ProcessingYear  INT = NULL,
    @ProcessingMonth INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET LOCK_TIMEOUT 5000;

    SET @ProcessingYear  = ISNULL(@ProcessingYear,  YEAR(GETUTCDATE()));
    SET @ProcessingMonth = ISNULL(@ProcessingMonth, MONTH(GETUTCDATE()));

    BEGIN TRY
        -- שלב 1: בדיקת קיום בקשה
        IF NOT EXISTS (SELECT 1 FROM RefundRequests WHERE RequestId = @RequestId)
        BEGIN
            SELECT 'ERROR'           AS Result,
                   N'בקשה לא נמצאה' AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @CalculatedAmount DECIMAL(10,2);
        DECLARE @CurrentStatus    NVARCHAR(50);

        -- שלב 2: נועל את השורה
        SELECT
            @CalculatedAmount = CalculatedAmount,
            @CurrentStatus    = Status
        FROM RefundRequests WITH (UPDLOCK, HOLDLOCK)
        WHERE RequestId = @RequestId;

        -- שלב 3: בדיקת סטטוס
        IF @CurrentStatus != 'WaitingApproval'
        BEGIN
            ROLLBACK TRANSACTION;

            DECLARE @StatusMessage NVARCHAR(500) =
                CASE @CurrentStatus
                    WHEN 'WaitingCalculation' THEN N'הבקשה טרם חושבה. יש ללחוץ על כפתור חשב תחילה'
                    WHEN 'Approved'           THEN N'הבקשה כבר אושרה ולא ניתן לשנותה'
                    WHEN 'Rejected'           THEN N'הבקשה כבר נדחתה ולא ניתן לשנותה'
                    WHEN 'Paid'               THEN N'הבקשה כבר שולמה ולא ניתן לשנותה'
                    ELSE N'הבקשה במצב לא תקין: ' + @CurrentStatus
                END;

            SELECT 'ERROR'        AS Result,
                   @StatusMessage AS Message;
            RETURN;
        END

        -- שלב 4: בדיקת סכום
        IF @CalculatedAmount IS NULL OR @CalculatedAmount <= 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 'ERROR'                  AS Result,
                   N'סכום מחושב אינו תקין' AS Message;
            RETURN;
        END

        -- שלב 5: דחייה
        IF @IsApproved = 0
        BEGIN
            UPDATE RefundRequests
            SET Status         = 'Rejected',
                ApprovedAmount = 0,
                ProcessedAt    = GETUTCDATE(),
                ProcessedBy    = @ProcessedBy
            WHERE RequestId = @RequestId;

            COMMIT TRANSACTION;

            SELECT 'REJECTED'      AS Result,
                   N'הבקשה נדחתה' AS Message,
                   0               AS ApprovedAmount;
            RETURN;
        END

        -- שלב 6: הקצאת תקציב אטומית
        DECLARE @Success         BIT;
        DECLARE @AllocMessage    NVARCHAR(500);
        DECLARE @RemainingBudget DECIMAL(12,2);

        EXEC sp_AllocateBudgetAtomically
            @ProcessingYear, @ProcessingMonth, @CalculatedAmount,
            @Success         OUTPUT,
            @AllocMessage    OUTPUT,
            @RemainingBudget OUTPUT;

        IF @Success = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 'REJECTED'    AS Result,
                   @AllocMessage AS Message,
                   0             AS ApprovedAmount;
            RETURN;
        END

        -- שלב 7: עדכון סופי
        UPDATE RefundRequests
        SET Status         = 'Approved',
            ApprovedAmount = @CalculatedAmount,
            ProcessedAt    = GETUTCDATE(),
            ProcessedBy    = @ProcessedBy
        WHERE RequestId = @RequestId;

        COMMIT TRANSACTION;

        SELECT
            'APPROVED'             AS Result,
            N'הבקשה אושרה בהצלחה' AS Message,
            @CalculatedAmount      AS ApprovedAmount,
            @RemainingBudget       AS RemainingBudget;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        IF ERROR_NUMBER() = 1222
        BEGIN
            SELECT 'ERROR'  AS Result,
                   N'הבקשה כרגע בטיפול על ידי פקיד אחר. אנא נסה שוב בעוד מספר שניות' AS Message,
                   0        AS ApprovedAmount;
            RETURN;
        END

        SELECT
            'ERROR'                             AS Result,
            N'שגיאה טכנית: ' + ERROR_MESSAGE() AS Message,
            0                                   AS ApprovedAmount;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_CheckBudgetAvailability]    Script Date: 08/03/2026 07:56:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CheckBudgetAvailability]
    @BudgetYear INT,
    @BudgetMonth INT,
    @RequiredAmount DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TotalBudget DECIMAL(12,2) = 0;
    DECLARE @UsedBudget DECIMAL(12,2) = 0;
    DECLARE @AvailableBudget DECIMAL(12,2) = 0;
    
    SELECT 
        @TotalBudget = TotalBudget,
        @UsedBudget = UsedBudget,
        @AvailableBudget = TotalBudget - UsedBudget
    FROM MonthlyBudgets 
    WHERE BudgetYear = @BudgetYear AND BudgetMonth = @BudgetMonth;
    
    IF @@ROWCOUNT = 0
    BEGIN
        SELECT 
            CAST(0 AS BIT) AS IsAvailable,
            0 AS AvailableBudget,
            N'תקציב לא קיים עבור ' + CAST(@BudgetMonth AS NVARCHAR) + '/' + CAST(@BudgetYear AS NVARCHAR) AS Message;
        RETURN;
    END
    
    IF @RequiredAmount > @AvailableBudget
    BEGIN
        SELECT 
            CAST(0 AS BIT) AS IsAvailable,
            @AvailableBudget AS AvailableBudget,
            N'תקציב לא מספיק. זמין: ' + FORMAT(@AvailableBudget, 'N2') + 
            N' ש"ח, נדרש: ' + FORMAT(@RequiredAmount, 'N2') + N' ש"ח' AS Message;
        RETURN;
    END
    
    SELECT 
        CAST(1 AS BIT) AS IsAvailable,
        @AvailableBudget AS AvailableBudget,
        N'תקציב זמין: ' + FORMAT(@AvailableBudget, 'N2') + N' ש"ח' AS Message;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ProcessRefundRequest]    Script Date: 08/03/2026 07:56:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ProcessRefundRequest]
    @RequestId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @CurrentStatus    NVARCHAR(50);
        DECLARE @CitizenId        INT;
        DECLARE @TaxYear          INT;
        DECLARE @CalcAmount       DECIMAL(10,2);
        DECLARE @AvgIncome        DECIMAL(10,2);
        DECLARE @IsValid          BIT;
        DECLARE @ErrorCode        INT;
        DECLARE @ErrorMessage     NVARCHAR(500);
        DECLARE @MonthsCount      INT;
        DECLARE @AvailableBudget  DECIMAL(12,2);
        DECLARE @BudgetMessage    NVARCHAR(500);
        DECLARE @RequestDate      DATE;
        DECLARE @ProcessingYear   INT;
        DECLARE @ProcessingMonth  INT;

        SELECT 
            @CurrentStatus = Status,
            @CitizenId     = CitizenId,
            @TaxYear       = TaxYear,
            @RequestDate   = RequestDate
        FROM RefundRequests
        WHERE RequestId = @RequestId;

        SET @ProcessingYear  = YEAR(@RequestDate);
        SET @ProcessingMonth = MONTH(@RequestDate);

        IF @CurrentStatus IS NULL
        BEGIN
            SELECT 'ERROR'           AS Result,
                   N'בקשה לא נמצאה' AS Message,
                   @RequestId        AS RequestId,
                   0                 AS CalculatedAmount,
                   0                 AS AvailableBudget,
                   ''                AS BudgetMessage;
            RETURN;
        END

        IF @CurrentStatus != 'WaitingCalculation'
        BEGIN
            DECLARE @ProcessStatusMessage NVARCHAR(500) =
                CASE @CurrentStatus
                    WHEN 'WaitingApproval' THEN N'הבקשה כבר בטיפול אצל פקיד אחר'
                    WHEN 'Approved'        THEN N'הבקשה כבר אושרה'
                    WHEN 'Rejected'        THEN N'הבקשה כבר נדחתה'
                    WHEN 'Paid'            THEN N'הבקשה כבר שולמה'
                    ELSE N'בקשה אינה במצב המתאים לחישוב. מצב נוכחי: ' + @CurrentStatus
                END;

            SELECT 'ERROR'               AS Result,
                   @ProcessStatusMessage AS Message,
                   @RequestId            AS RequestId,
                   0                     AS CalculatedAmount,
                   0                     AS AvailableBudget,
                   ''                    AS BudgetMessage;
            RETURN;
        END

        EXEC sp_ValidateEligibility
            @CitizenId        = @CitizenId,
            @TaxYear          = @TaxYear,
            @ExcludeRequestId = @RequestId,
            @IsValid          = @IsValid      OUTPUT,
            @ErrorCode        = @ErrorCode    OUTPUT,
            @ErrorMessage     = @ErrorMessage OUTPUT,
            @MonthsCount      = @MonthsCount  OUTPUT,
            @AvgIncome        = @AvgIncome    OUTPUT;

        IF @IsValid = 0
        BEGIN
            UPDATE RefundRequests
            SET Status = 'Rejected'
            WHERE RequestId = @RequestId;

            SELECT 'REJECTED'     AS Result,
                   @ErrorMessage  AS Message,
                   @RequestId     AS RequestId,
                   0              AS CalculatedAmount,
                   0              AS AvailableBudget,
                   ''             AS BudgetMessage;
            RETURN;
        END

        SET @CalcAmount = dbo.fn_CalculateTieredAmount(@AvgIncome);

        IF @CalcAmount = 0
        BEGIN
            UPDATE RefundRequests
            SET Status = 'Rejected'
            WHERE RequestId = @RequestId;

            SELECT 'REJECTED'                                      AS Result,
                   N'ההכנסה הממוצעת עולה על הסף המזכה בהחזר מס'  AS Message,
                   @RequestId                                      AS RequestId,
                   0                                               AS CalculatedAmount,
                   0                                               AS AvailableBudget,
                   ''                                              AS BudgetMessage;
            RETURN;
        END

        UPDATE RefundRequests
        SET Status           = 'WaitingApproval',
            CalculatedAmount = @CalcAmount
        WHERE RequestId = @RequestId;

        DECLARE @BudgetResults TABLE (
            IsAvailable     BIT,
            AvailableBudget DECIMAL(12,2),
            Message         NVARCHAR(500)
        );

        INSERT INTO @BudgetResults
        EXEC sp_CheckBudgetAvailability @ProcessingYear, @ProcessingMonth, @CalcAmount;

        SELECT 
            @AvailableBudget = AvailableBudget,
            @BudgetMessage   = Message
        FROM @BudgetResults;

        SELECT 
            'WAITING_APPROVAL'   AS Result,
            N'ממתין להחלטת פקיד' AS Message,
            @RequestId           AS RequestId,
            @CalcAmount          AS CalculatedAmount,
            @AvailableBudget     AS AvailableBudget,
            @BudgetMessage       AS BudgetMessage;

    END TRY
    BEGIN CATCH
        SELECT 
            'ERROR'                             AS Result,
            N'שגיאה טכנית: ' + ERROR_MESSAGE() AS Message,
            @RequestId                          AS RequestId,
            0                                   AS CalculatedAmount,
            0                                   AS AvailableBudget,
            ''                                  AS BudgetMessage;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ValidateEligibility]    Script Date: 08/03/2026 07:56:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ValidateEligibility]
    @CitizenId        INT,
    @TaxYear          INT,
    @ExcludeRequestId INT           = NULL,
    @IsValid          BIT           OUTPUT,
    @ErrorCode        INT           OUTPUT,
    @ErrorMessage     NVARCHAR(500) OUTPUT,
    @MonthsCount      INT           OUTPUT,
    @AvgIncome        DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    SET @MonthsCount = 0;
    SET @AvgIncome   = 0;
    
    SELECT 
        @MonthsCount = COUNT(*), 
        @AvgIncome   = ISNULL(AVG(IncomeAmount), 0)
    FROM MonthlyIncomes 
    WHERE CitizenId = @CitizenId AND TaxYear = @TaxYear;
    
    IF @MonthsCount < 6
    BEGIN
        SET @IsValid      = 0;
        SET @ErrorCode    = 2001;
        SET @ErrorMessage = N'נדרשים לפחות 6 חודשי הכנסה. נמצאו: ' + CAST(@MonthsCount AS NVARCHAR);
        RETURN;
    END
    
    IF EXISTS (
        SELECT 1 FROM RefundRequests 
        WHERE CitizenId = @CitizenId 
        AND TaxYear     = @TaxYear 
        AND (@ExcludeRequestId IS NULL OR RequestId != @ExcludeRequestId)
        AND Status IN ('Approved', 'Paid')
    )
    BEGIN
        SET @IsValid      = 0;
        SET @ErrorCode    = 2002;
        SET @ErrorMessage = N'כבר קיימת בקשה מאושרת עבור שנת מס ' + CAST(@TaxYear AS NVARCHAR);
        RETURN;
    END
    
    SET @IsValid      = 1;
    SET @ErrorCode    = 0;
    SET @ErrorMessage = N'בדיקות זכאות עברו בהצלחה';
END
GO
USE [master]
GO
ALTER DATABASE [RefundEligibilityDB] SET  READ_WRITE 
GO
