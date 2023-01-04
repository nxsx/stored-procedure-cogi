USE [S4]
GO
/****** Object:  StoredProcedure [dbo].[spHTCPPCogiReport]    Script Date: 1/4/2023 1:24:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,Thanat Dampawanwong>
-- Create date: <Create Date,20211019 1030AM>
-- Description:	<Description,Cogi with stock comparison>
-- =============================================
ALTER PROCEDURE [dbo].[spHTCPPCogiReport] 
	-- Add the parameters for the stored procedure here
	@PDate char(8) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tempTable TABLE (
        [PLANT] VARCHAR(4),
        [MATERIAL] VARCHAR(100),
        [LOCATION] VARCHAR(4),
        [STOCK] DECIMAL(18, 3),
        [TYPE] VARCHAR(1) 
	);

    -- Insert statements for procedure here

	INSERT INTO @tempTable SELECT [S4].[dbo].[MARD].[PLANT], 
		[S4].[dbo].[MARD].[MATERIAL], 
		[S4].[dbo].[MARD].[LOCATION], 
		SUM([S4].[dbo].[MARD].[UNRESTRICTED]) AS [STOCK], 
		[S4].[dbo].[T001L].[TYPE] 
	FROM [S4].[dbo].[MARD] (NOLOCK) 
	LEFT JOIN [S4].[dbo].[T001L] ON [S4].[dbo].[MARD].[PLANT] = [S4].[dbo].[T001L].[PLANT] 
	AND [S4].[dbo].[MARD].[LOCATION] = [S4].[dbo].[T001L].[LOCATION] 
	WHERE [S4].[dbo].[T001L].[ACTIVE] = '1' 
	AND [S4].[dbo].[T001L].[TYPE] IN ('R', 'P') 
	AND CONVERT(VARCHAR, [S4].[dbo].[MARD].[TIME_STAMP], 112) = @PDate 
	GROUP BY [S4].[dbo].[MARD].[PLANT], 
		[S4].[dbo].[MARD].[MATERIAL], 
		[S4].[dbo].[MARD].[LOCATION], 
		[S4].[dbo].[T001L].[TYPE] 
	ORDER BY [S4].[dbo].[MARD].[PLANT], 
		[S4].[dbo].[MARD].[LOCATION]; 

	SELECT 
		[AFFW].[PLANT], [AFFW].[ORDER_NO], [AFFW].[MATERIAL], 
		[dbo].[fnCogiGetMatDesc] ([AFFW].[PLANT], [AFFW].[MATERIAL]) AS [DESCRIPTION], 
		[AFFW].[LOCATION] AS [COGI_SLOC], 
		CASE
			WHEN [AFFW].[LOCATION] IN('ASKD', 'IABO', 'IABP', 'IAC0', 'IAC1', 'IAC2', 'IAC5', 'IAC6', 'IACT', 'IAFC', 'RABO', 'RABP', 'RAC0', 'RAC1', 'RAC2', 'RAC3', 'RAC4', 'RAC5', 'RAC6', 'RAC7', 'RAC9', 'RACT', 'RADG', 'RAEM', 'RAEP', 'RAFC', 'RAFP', 'RAGS', 'RAHL', 'RAIL', 'RAIN', 'RAIU', 'RAPO', 'RATM', 'RAWS') 
				THEN 'A' 
			WHEN [AFFW].[LOCATION] IN('BSKD', 'IBBO', 'IBBP', 'IBC0', 'IBC1', 'IBC2', 'IBC4', 'IBC5', 'IBC6', 'IBCT', 'IBFC', 'IBTM', 'RBB2', 'RBBO', 'RBBP', 'RBC0', 'RBC1', 'RBC2', 'RBC4', 'RBC5', 'RBC6', 'RBC7', 'RBC9', 'RBCT', 'RBDG', 'RBEP', 'RBFC', 'RBFE', 'RBFP', 'RBHL', 'RBIN', 'RBPO', 'RBTM', 'RBWS', 'RBWS') 
				THEN 'B' 
			WHEN [AFFW].[LOCATION] IN('IAD1', 'IADL', 'IBD1', 'IBDL', 'ICD1', 'ICDL', 'RAD1', 'RAD2', 'RAD3', 'RADL', 'RBD1', 'RBD2', 'RBD3', 'RBDL', 'RCD1', 'RCD2', 'RCD3', 'RCDL') 
				THEN 'D' 
			WHEN [AFFW].[LOCATION] IN('0201', '0202', '0203', '0204', '0205', '0206') 
				THEN 'EV' 
			WHEN [AFFW].[LOCATION] IN('0101', '0102', '0103', '0104') 
				THEN 'PP' 
			WHEN [AFFW].[LOCATION] IN('RDLN', 'REXT', 'RILN') 
				THEN 'TF' 
			WHEN [AFFW].[LOCATION] IN('1201', 'RDDP', 'RFCM', 'RFEA', 'RPCM', 'RPSS', 'RPST', 'RSHE', 'RTEC') 
				THEN 'MCMP' 
			WHEN [AFFW].[LOCATION] IN('0300', '0301', '0302', '0303', '0304', '0305', '0306', '0307', '0308', '0309', '0310', '0311', '0312', '0313', '0314') 
				THEN 'W1' 
			WHEN [AFFW].[LOCATION] IN('0400', '0401', '0402', '0403', '0404', '0405', '0406', '0407', '0408', '0409', '0410', '0411', '0412', '0413', '0414') 
				THEN 'W2' 
			WHEN [AFFW].[LOCATION] IN('ACAC', 'ACPD', 'AFPD') 
				THEN 'AIR' 
			WHEN [AFFW].[LOCATION] IN('BSN1', 'BSN2', 'N101', 'N102', 'N103', 'N104', 'N105', 'N106', 'N107', 'N108', 'N109', 'N201', 'N202', 'N203', 'N204', 'N205', 'N206', 'N207', 'N208', 'N209') 
				THEN 'AIR (IN DOOR)' 
			WHEN [AFFW].[LOCATION] IN('BSU1', 'BSU2', 'U101', 'U102', 'U103', 'U104', 'U105', 'U106', 'U107', 'U108', 'U109', 'U110', 'U111', 'U201', 'U202', 'U203', 'U204', 'U205', 'U206', 'U207', 'U208', 'U209', 'U210', 'U211') 
				THEN 'AIR (OUT DOOR)' 
			WHEN [AFFW].[LOCATION] IN('0088', '0099', '0076', '0077') 
				THEN 'FG' 
			ELSE 'OTHER' 
		END AS [COGI_LINE], 
		[AFFW].[QUANTITY] AS [COGI_QTY], 
		[AFFW].[UNIT], [AFFW].[MRP], CONVERT(VARCHAR, [AFFW].[POSTING_DATE], 120) AS [POSTING_DATE], 
		[MARD].[STOCK] AS [STOCK_QTY], [MARD].[LOCATION] AS [STOCK_SLOC], 
		CASE
			WHEN [MARD].[TYPE] = 'R' THEN 'RMWH'
			WHEN [MARD].[TYPE] = 'P' THEN 'SFGWH'
			WHEN [MARD].[TYPE] = 'L' THEN 'WIP'
			ELSE '' 
		END AS [STOCK_TYPE], 
		CASE 
			WHEN ([AFFW].[MRP] IN('H01', 'H02', 'H03', 'H04', 'H06', 'H11', 'H13', 'H23', 'H31', 'H51') AND [MARD].[STOCK] >= [AFFW].[QUANTITY]) THEN 'NO SFG HANDOVER' 
			WHEN ([AFFW].[MRP] IN('H01', 'H02', 'H03', 'H04', 'H06', 'H11', 'H13', 'H23', 'H31', 'H51') AND [MARD].[STOCK] < [AFFW].[QUANTITY]) THEN 'NO SFG OFFLINE' 
			WHEN ([AFFW].[MRP] IN('H01', 'H02', 'H03', 'H04', 'H06', 'H11', 'H13', 'H23', 'H31', 'H51') AND [MARD].[STOCK] IS NULL) THEN 'NO SFG OFFLINE' 
			WHEN ([AFFW].[MRP] NOT IN('H01', 'H02', 'H03', 'H04', 'H06', 'H11', 'H13', 'H23', 'H31', 'H51') AND [MARD].[STOCK] >= [AFFW].[QUANTITY]) THEN 'NO RMWH HANDOVER' 
			WHEN ([AFFW].[MRP] NOT IN('H01', 'H02', 'H03', 'H04', 'H06', 'H11', 'H13', 'H23', 'H31', 'H51') AND [MARD].[STOCK] < [AFFW].[QUANTITY]) THEN 'NO RMWH DNGR' 
			WHEN ([AFFW].[MRP] NOT IN('H01', 'H02', 'H03', 'H04', 'H06', 'H11', 'H13', 'H23', 'H31', 'H51') AND [MARD].[STOCK] IS NULL) THEN 'NO RMWH DNGR' 
			WHEN [MARD].[TYPE] IS NULL THEN 'NO RMWH DNGR' 
			ELSE 'NO RELATED' 
		END AS [COGI_CASE] 
	FROM [S4].[dbo].[AFFW] AS [AFFW] 
	LEFT JOIN @tempTable AS [MARD] ON [AFFW].[PLANT] = [MARD].[PLANT] 
	AND [AFFW].[MATERIAL] = [MARD].[MATERIAL] 
	WHERE [AFFW].[MESSAGE_NO] = '021' 
	AND CONVERT(VARCHAR, [AFFW].[TIME_STAMP], 112) = @PDate 
	AND CONVERT(VARCHAR, [AFFW].[POSTING_DATE], 112) < @PDate 
	-- AND CONVERT(VARCHAR, [AFFW].[TIME_STAMP], 112) = @PDate #Change to posting date less than current 
	ORDER BY [AFFW].[PLANT], 
		[AFFW].[ORDER_NO], 
		[AFFW].[MATERIAL], 
		[AFFW].[LOCATION], 
		[AFFW].[QUANTITY], 
		[AFFW].[TIME_STAMP]; 

END
