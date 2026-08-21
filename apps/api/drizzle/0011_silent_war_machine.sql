ALTER TABLE "payments" ADD COLUMN "withdrawal_consent_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "receipts" ADD COLUMN "withdrawal_consent_at" timestamp with time zone;