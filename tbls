
BEGIN;

CREATE DATABASE "HomeShelter"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = 'libc'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

CREATE TABLE IF NOT EXISTS public."CaseNote"
(
    "CaseNoteID" uuid NOT NULL,
    "ClientID" uuid NOT NULL,
    "AuthorUserID" uuid NOT NULL,
    "NoteText" text COLLATE pg_catalog."default" NOT NULL,
    "NoteDate" timestamp without time zone NOT NULL DEFAULT now(),
    "Visibility" character varying(30) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "CaseNote_pkey" PRIMARY KEY ("CaseNoteID")
);

CREATE TABLE IF NOT EXISTS public."Client"
(
    "ClientID" uuid NOT NULL,
    "FirstName" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "LastName" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "DOB" date,
    "Gender" character varying(50) COLLATE pg_catalog."default",
    "Phone" character varying(30) COLLATE pg_catalog."default",
    "Email" character varying(254) COLLATE pg_catalog."default",
    "Address" character varying(200) COLLATE pg_catalog."default",
    "City" character varying(100) COLLATE pg_catalog."default",
    "State" character(2) COLLATE pg_catalog."default",
    "Zip" character varying(10) COLLATE pg_catalog."default",
    "IntakeDate" date NOT NULL,
    "IntakeStaffUserID" uuid NOT NULL,
    "IsActive" boolean NOT NULL DEFAULT true,
    "CreatedAt" timestamp without time zone NOT NULL,
    "UpdatedAt" timestamp without time zone NOT NULL,
    CONSTRAINT "Client_pkey" PRIMARY KEY ("ClientID")
);

CREATE TABLE IF NOT EXISTS public."InventoryCategory"
(
    "CategoryID" uuid NOT NULL,
    "Name" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "InventoryCategory_pkey" PRIMARY KEY ("CategoryID"),
    CONSTRAINT "InventoryCategory_Name_key" UNIQUE ("Name")
);

COMMENT ON TABLE public."InventoryCategory"
    IS 'Reference list of inventory categories (e.g., Food, Hygiene, Medical, Clothing, Supplies).';

CREATE TABLE IF NOT EXISTS public."InventoryItem"
(
    "ItemID" uuid NOT NULL,
    "Name" character varying(150) COLLATE pg_catalog."default" NOT NULL,
    "CategoryID" uuid NOT NULL,
    "UoMID" uuid NOT NULL,
    "ManagesExpiration" boolean NOT NULL DEFAULT false,
    "ReorderPoint" numeric(12, 2),
    "IsActive" boolean NOT NULL DEFAULT true,
    CONSTRAINT "InventoryItem_pkey" PRIMARY KEY ("ItemID"),
    CONSTRAINT "InventoryItem_CategoryID_Name_key" UNIQUE ("CategoryID", "Name")
);

COMMENT ON TABLE public."InventoryItem"
    IS 'Inventory items; Name unique within Category. Tracks unit of measure and whether lots/expirations are managed.';

COMMENT ON COLUMN public."InventoryItem"."ManagesExpiration"
    IS 'TRUE if item requires lot/expiration tracking; otherwise FALSE.';

CREATE TABLE IF NOT EXISTS public."InventoryTransaction"
(
    "TxnID" uuid NOT NULL,
    "ItemID" uuid NOT NULL,
    "TxnType" character varying(15) COLLATE pg_catalog."default" NOT NULL,
    "Quantity" numeric(12, 2) NOT NULL,
    "LotNumber" character varying(50) COLLATE pg_catalog."default",
    "ExpirationDate" date,
    "PerformedByUserID" uuid NOT NULL,
    "TxnDate" timestamp without time zone NOT NULL DEFAULT now(),
    "Notes" character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT "InventoryTransaction_pkey" PRIMARY KEY ("TxnID")
);

CREATE TABLE IF NOT EXISTS public."Program"
(
    "ProgramID" uuid NOT NULL,
    "Name" character varying(150) COLLATE pg_catalog."default" NOT NULL,
    "Description" text COLLATE pg_catalog."default",
    "Category" character varying(100) COLLATE pg_catalog."default",
    "IsActive" boolean NOT NULL DEFAULT true,
    "CreatedByUserID" uuid NOT NULL,
    "CreatedAt" timestamp without time zone NOT NULL,
    "UpdatedAt" timestamp without time zone NOT NULL,
    CONSTRAINT "Program_pkey" PRIMARY KEY ("ProgramID"),
    CONSTRAINT "Program_Name_key" UNIQUE ("Name")
);

CREATE TABLE IF NOT EXISTS public."ServiceInteraction"
(
    "ServiceInteractionID" uuid NOT NULL,
    "ClientID" uuid NOT NULL,
    "ProgramID" uuid NOT NULL,
    "InteractionDate" date NOT NULL,
    "Units" numeric(10, 2),
    "CreatedByUserID" uuid NOT NULL,
    "Notes" character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT "ServiceInteraction_pkey" PRIMARY KEY ("ServiceInteractionID")
);

CREATE TABLE IF NOT EXISTS public."UnitOfMeasure"
(
    "UoMID" uuid NOT NULL,
    "Name" character varying(50) COLLATE pg_catalog."default" NOT NULL,
    "Abbrev" character varying(10) COLLATE pg_catalog."default",
    CONSTRAINT "UnitOfMeasure_pkey" PRIMARY KEY ("UoMID"),
    CONSTRAINT "UnitOfMeasure_Name_key" UNIQUE ("Name")
);

COMMENT ON TABLE public."UnitOfMeasure"
    IS 'Reference list of units of measure (e.g., each, box, lb, oz).';

CREATE TABLE IF NOT EXISTS public."User"
(
    "UserID" uuid NOT NULL,
    "Username" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "PasswordHash" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "Role" character varying(50) COLLATE pg_catalog."default" NOT NULL,
    "FirstName" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "LastName" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "Email" character varying(254) COLLATE pg_catalog."default" NOT NULL,
    "Phone" character varying(30) COLLATE pg_catalog."default",
    "IsActive" boolean NOT NULL DEFAULT true,
    "CreatedAt" timestamp without time zone NOT NULL,
    "UpdatedAt" timestamp without time zone NOT NULL,
    CONSTRAINT "User_pkey" PRIMARY KEY ("UserID"),
    CONSTRAINT "User_Email_key" UNIQUE ("Email"),
    CONSTRAINT "User_Username_key" UNIQUE ("Username")
);

COMMENT ON TABLE public."User"
    IS 'Authorized staff/system users';

COMMENT ON COLUMN public."User"."PasswordHash"
    IS 'Stored securely; never plain text';

COMMENT ON COLUMN public."User"."Role"
    IS 'Examples: Admin, Caseworker, VolunteerMgr, InventoryMgr, DevOfficer';

ALTER TABLE IF EXISTS public."CaseNote"
    ADD CONSTRAINT "CaseNote_AuthorUserID_fkey" FOREIGN KEY ("AuthorUserID")
    REFERENCES public."User" ("UserID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public."CaseNote"
    ADD CONSTRAINT "CaseNote_ClientID_fkey" FOREIGN KEY ("ClientID")
    REFERENCES public."Client" ("ClientID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public."Client"
    ADD CONSTRAINT "Client_IntakeStaffUserID_fkey" FOREIGN KEY ("IntakeStaffUserID")
    REFERENCES public."User" ("UserID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public."InventoryItem"
    ADD CONSTRAINT "InventoryItem_CategoryID_fkey" FOREIGN KEY ("CategoryID")
    REFERENCES public."InventoryCategory" ("CategoryID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS "ix_InventoryItem_CategoryID"
    ON public."InventoryItem"("CategoryID");


ALTER TABLE IF EXISTS public."InventoryItem"
    ADD CONSTRAINT "InventoryItem_UoMID_fkey" FOREIGN KEY ("UoMID")
    REFERENCES public."UnitOfMeasure" ("UoMID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS "ix_InventoryItem_UoMID"
    ON public."InventoryItem"("UoMID");


ALTER TABLE IF EXISTS public."InventoryTransaction"
    ADD CONSTRAINT "InventoryTransaction_ItemID_fkey" FOREIGN KEY ("ItemID")
    REFERENCES public."InventoryItem" ("ItemID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS "ix_InventoryTransaction_ItemID"
    ON public."InventoryTransaction"("ItemID");


ALTER TABLE IF EXISTS public."InventoryTransaction"
    ADD CONSTRAINT "InventoryTransaction_PerformedByUserID_fkey" FOREIGN KEY ("PerformedByUserID")
    REFERENCES public."User" ("UserID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS "ix_InventoryTransaction_PerformedByUserID"
    ON public."InventoryTransaction"("PerformedByUserID");


ALTER TABLE IF EXISTS public."Program"
    ADD CONSTRAINT "Program_CreatedByUserID_fkey" FOREIGN KEY ("CreatedByUserID")
    REFERENCES public."User" ("UserID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public."ServiceInteraction"
    ADD CONSTRAINT "ServiceInteraction_ClientID_fkey" FOREIGN KEY ("ClientID")
    REFERENCES public."Client" ("ClientID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS "ix_ServiceInteraction_ClientID"
    ON public."ServiceInteraction"("ClientID");


ALTER TABLE IF EXISTS public."ServiceInteraction"
    ADD CONSTRAINT "ServiceInteraction_CreatedByUserID_fkey" FOREIGN KEY ("CreatedByUserID")
    REFERENCES public."User" ("UserID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS "ix_ServiceInteraction_CreatedByUserID"
    ON public."ServiceInteraction"("CreatedByUserID");


ALTER TABLE IF EXISTS public."ServiceInteraction"
    ADD CONSTRAINT "ServiceInteraction_ProgramID_fkey" FOREIGN KEY ("ProgramID")
    REFERENCES public."Program" ("ProgramID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS "ix_ServiceInteraction_ProgramID"
    ON public."ServiceInteraction"("ProgramID");

END;
