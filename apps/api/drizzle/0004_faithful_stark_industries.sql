CREATE SEQUENCE "public"."receipt_number_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1;--> statement-breakpoint
CREATE TABLE "receipts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"payment_id" uuid,
	"payment_ref" text NOT NULL,
	"receipt_number" text NOT NULL,
	"product_description" text NOT NULL,
	"amount_gross_minor" integer NOT NULL,
	"amount_net_minor" integer NOT NULL,
	"vat_amount_minor" integer NOT NULL,
	"vat_rate_bps" integer NOT NULL,
	"currency" text DEFAULT 'SEK' NOT NULL,
	"payment_method" text NOT NULL,
	"payment_status" text DEFAULT 'confirmed' NOT NULL,
	"refund_status" text DEFAULT 'none' NOT NULL,
	"seller_name" text NOT NULL,
	"seller_org_number" text,
	"seller_vat_number" text,
	"email" text,
	"email_status" text DEFAULT 'pending' NOT NULL,
	"email_sent_at" timestamp with time zone,
	"issued_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "payments" ADD COLUMN "receipt_email" text;--> statement-breakpoint
ALTER TABLE "receipts" ADD CONSTRAINT "receipts_payment_id_payments_id_fk" FOREIGN KEY ("payment_id") REFERENCES "public"."payments"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "receipts_payment_uq" ON "receipts" USING btree ("payment_id");--> statement-breakpoint
CREATE UNIQUE INDEX "receipts_number_uq" ON "receipts" USING btree ("receipt_number");--> statement-breakpoint
CREATE INDEX "receipts_tenant_idx" ON "receipts" USING btree ("tenant_id");