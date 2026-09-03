CREATE TABLE "feedback" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid,
	"user_id" uuid,
	"category" text NOT NULL,
	"page" text NOT NULL,
	"opportunity_slug" text,
	"message" text NOT NULL,
	"locale" text,
	"user_agent" text,
	"status" text DEFAULT 'new' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "product_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid,
	"user_id" uuid,
	"name" text NOT NULL,
	"props" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE INDEX "feedback_status_idx" ON "feedback" USING btree ("status","created_at");--> statement-breakpoint
CREATE INDEX "feedback_opportunity_idx" ON "feedback" USING btree ("opportunity_slug");--> statement-breakpoint
CREATE INDEX "product_events_name_idx" ON "product_events" USING btree ("name","created_at");--> statement-breakpoint
CREATE INDEX "product_events_tenant_idx" ON "product_events" USING btree ("tenant_id","created_at");--> statement-breakpoint
-- RLS-invarianten (migrering 0005): varje ny tabell är deny-all mot direkt databasåtkomst.
ALTER TABLE "feedback" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
ALTER TABLE "product_events" ENABLE ROW LEVEL SECURITY;
