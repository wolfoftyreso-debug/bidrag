-- Supabase-härdning: PostgREST exponerar public-schemat för innehavare av
-- anon-/publishable-nyckeln. Bidrag.se:s enda databasklient är API:t (ansluter
-- som tabellägare och påverkas inte av RLS). Därför: RLS PÅ för samtliga
-- tabeller, UTAN policies = deny-all för PostgREST-vägen, och alla grants för
-- anon/authenticated återkallas. Nya tabeller måste göra samma sak i sin
-- migration (lintat i CI via scripts/check-rls.mjs).
DO $$
DECLARE t record;
BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'public'
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t.tablename);
  END LOOP;

  -- Supabase skapar rollerna anon/authenticated; lokalt/CI finns de inte.
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    EXECUTE 'REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon';
    EXECUTE 'REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon';
    EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM anon';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
    EXECUTE 'REVOKE ALL ON ALL TABLES IN SCHEMA public FROM authenticated';
    EXECUTE 'REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM authenticated';
    EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM authenticated';
  END IF;
END $$;
