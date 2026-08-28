CREATE TABLE "kb_translations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"locale" text NOT NULL,
	"source_text" text NOT NULL,
	"translated_text" text NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX "kb_translations_locale_source_idx" ON "kb_translations" USING btree ("locale","source_text");
-- RLS på (deny-all utan policy): nya tabeller måste följa migration 0005:s härdning.
ALTER TABLE "kb_translations" ENABLE ROW LEVEL SECURITY;
