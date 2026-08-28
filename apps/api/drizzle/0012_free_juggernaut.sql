CREATE TABLE "storage_objects" (
	"path" text PRIMARY KEY NOT NULL,
	"tenant_id" uuid,
	"content_type" text DEFAULT 'application/octet-stream' NOT NULL,
	"content" "bytea" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE INDEX "storage_objects_tenant_idx" ON "storage_objects" USING btree ("tenant_id");--> statement-breakpoint
-- RLS på (deny-all utan policy): nya tabeller måste följa migration 0005:s härdning.
ALTER TABLE "storage_objects" ENABLE ROW LEVEL SECURITY;
