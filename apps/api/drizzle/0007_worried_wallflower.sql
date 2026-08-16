CREATE TABLE "generated_documents" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"project_id" uuid NOT NULL,
	"opportunity_slug" text,
	"opportunity_title" text NOT NULL,
	"template_key" text NOT NULL,
	"title" text NOT NULL,
	"content" text NOT NULL,
	"answers" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"created_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "payments" ADD COLUMN "credits" integer;--> statement-breakpoint
ALTER TABLE "generated_documents" ADD CONSTRAINT "generated_documents_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "generated_documents" ADD CONSTRAINT "generated_documents_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "generated_documents" ADD CONSTRAINT "generated_documents_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "generated_documents_tenant_idx" ON "generated_documents" USING btree ("tenant_id","project_id");--> statement-breakpoint
-- RLS-invarianten: varje ny tabell är deny-all mot PostgREST-vägen.
ALTER TABLE "generated_documents" ENABLE ROW LEVEL SECURITY;
