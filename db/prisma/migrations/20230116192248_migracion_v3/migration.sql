/*
  Warnings:

  - The primary key for the `TMP_Logs` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to alter the column `id` on the `TMP_Logs` table. The data in that column could be lost. The data in that column will be cast from `String` to `Int`.

*/
BEGIN TRY

BEGIN TRAN;

-- RedefineTables
BEGIN TRANSACTION;
DECLARE @SQL NVARCHAR(MAX) = N''
SELECT @SQL += N'ALTER TABLE '
    + QUOTENAME(OBJECT_SCHEMA_NAME(PARENT_OBJECT_ID))
    + '.'
    + QUOTENAME(OBJECT_NAME(PARENT_OBJECT_ID))
    + ' DROP CONSTRAINT '
    + OBJECT_NAME(OBJECT_ID) + ';'
FROM SYS.OBJECTS
WHERE TYPE_DESC LIKE '%CONSTRAINT'
    AND OBJECT_NAME(PARENT_OBJECT_ID) = 'TMP_Logs'
    AND SCHEMA_NAME(SCHEMA_ID) = 'dbo'
EXEC sp_executesql @SQL
;
CREATE TABLE [dbo].[_prisma_new_TMP_Logs] (
    [id] INT NOT NULL IDENTITY(1,1),
    [logText] VARCHAR(500) NOT NULL,
    [error] BIT NOT NULL CONSTRAINT [TMP_Logs_error_df] DEFAULT 0,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [TMP_Logs_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [updatedAt] DATETIME2 NOT NULL,
    CONSTRAINT [TMP_Logs_pkey] PRIMARY KEY CLUSTERED ([id])
);
SET IDENTITY_INSERT [dbo].[_prisma_new_TMP_Logs] ON;
IF EXISTS(SELECT * FROM [dbo].[TMP_Logs])
    EXEC('INSERT INTO [dbo].[_prisma_new_TMP_Logs] ([createdAt],[error],[id],[logText],[updatedAt]) SELECT [createdAt],[error],[id],[logText],[updatedAt] FROM [dbo].[TMP_Logs] WITH (holdlock tablockx)');
SET IDENTITY_INSERT [dbo].[_prisma_new_TMP_Logs] OFF;
DROP TABLE [dbo].[TMP_Logs];
EXEC SP_RENAME N'dbo._prisma_new_TMP_Logs', N'TMP_Logs';
COMMIT;

COMMIT TRAN;

END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
BEGIN
    ROLLBACK TRAN;
END;
THROW

END CATCH
