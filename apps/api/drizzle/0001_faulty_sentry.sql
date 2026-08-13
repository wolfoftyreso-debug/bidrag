CREATE INDEX "refresh_tokens_user_idx" ON "refresh_tokens" USING btree ("user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "reminders_case_kind_idx" ON "reminders" USING btree ("case_id","kind");--> statement-breakpoint
CREATE INDEX "review_items_status_idx" ON "review_items" USING btree ("status","created_at");--> statement-breakpoint
CREATE INDEX "submission_receipts_tenant_idx" ON "submission_receipts" USING btree ("tenant_id");