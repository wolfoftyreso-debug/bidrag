/**
 * Generation mode (AI-spec §32, konstitutionen §22–23): FÖRSLAG-och-GODKÄNN,
 * aldrig autopilot. Arkitekturen bär garantierna, inte modellen:
 *
 *  1. Ett förslag begärs per fält, med sökandens befintliga text som enda
 *     faktakälla. Tom text ger inget förslag — luckor fylls med frågor,
 *     aldrig med genererad text (§5).
 *  2. VARJE förslag passerar de deterministiska vakterna i @bidrag/core
 *     (uppfunna siffror, meta-spår, införda superlativ, längdsvall). Ett
 *     avvisat förslag visas aldrig för användaren.
 *  3. BEFORE/REASON/AFTER auditloggas (§32-spårbarheten).
 *  4. Att acceptera = sökanden PATCH:ar själv in texten via ordinarie
 *     svarsflöde. Systemet skriver aldrig i sökandens svar (§3, §30).
 *
 * Provider-modellen är samma som betalningarnas: Anthropic-adaptern aktiveras
 * av ANTHROPIC_API_KEY i driftmiljön; mocken är deterministisk och fungerar
 * aldrig i produktion.
 */
import Anthropic from '@anthropic-ai/sdk';
import { config } from '../config.ts';

export interface SuggestionRequest {
  fieldLabel: string;
  guidance?: string;
  before: string;
}

export interface SuggestionResult {
  after: string;
  reason: string;
}

export interface GenerationProvider {
  id: string;
  suggest(req: SuggestionRequest): Promise<SuggestionResult>;
}

/** Deterministisk mock för test/dev: typografi + ett känt ordbyte. */
const mockProvider: GenerationProvider = {
  id: 'mock',
  async suggest({ before }) {
    // Testkrok: låter testerna bevisa att vakterna avvisar uppfunna siffror.
    if (before.includes('[[MOCK-INVENT]]')) {
      return { after: `${before.replace('[[MOCK-INVENT]]', '').trim()} Detta skapar 9999 nya arbetstillfällen.`, reason: 'Mock: medvetet regelbrott för vakttest.' };
    }
    const after = before.replace(/\s{2,}/g, ' ').replace(/\bjättebra\b/gi, 'väl fungerande').trim();
    return { after, reason: 'Typografin städad och ett vardagsord ersatt med sakligare formulering. Inga sakuppgifter ändrade.' };
  },
};

const SYSTEM_PROMPT = [
  'Du förbättrar formuleringen i ETT fält i en svensk bidragsansökan. Sökandens text är enda faktakällan.',
  'Absoluta regler: hitta aldrig på siffror, namn, källor eller sakuppgifter; ta inte bort sakinnehåll;',
  'inga superlativ eller standardfraser ("härmed ansöker", "brinner för", "unik", "garanterar");',
  'ingen hänvisning till AI eller verktyg; behåll sökandens ton — saklig, konkret, ödmjuk utan att försvagas.',
  'improved är den förbättrade texten; reason beskriver på en mening sakligt vad som ändrades och varför.',
].join(' ');

/** Strukturerad utdata: svaret valideras mot schemat av API:t — aldrig fritolkad JSON. */
const SUGGESTION_SCHEMA = {
  type: 'object' as const,
  properties: {
    improved: { type: 'string' as const, description: 'Den förbättrade fälttexten, komplett.' },
    reason: { type: 'string' as const, description: 'En mening: vad som ändrades och varför.' },
  },
  required: ['improved', 'reason'],
  additionalProperties: false,
};

function anthropicProvider(apiKey: string): GenerationProvider {
  const client = new Anthropic({ apiKey });
  return {
    id: 'anthropic',
    async suggest({ fieldLabel, guidance, before }) {
      let response: Anthropic.Message;
      try {
        response = await client.messages.create({
          model: 'claude-opus-5',
          // Tänkande är på som standard på claude-opus-5 och räknas in i
          // max_tokens — därav marginalen. Kort språkuppgift ⇒ låg effort.
          max_tokens: 8192,
          output_config: { effort: 'low', format: { type: 'json_schema', schema: SUGGESTION_SCHEMA } },
          system: SYSTEM_PROMPT,
          messages: [
            {
              role: 'user',
              content: `Fält: ${fieldLabel}\n${guidance ? `Fältets vägledning: ${guidance}\n` : ''}Sökandens text:\n"""\n${before}\n"""`,
            },
          ],
        });
      } catch (err) {
        if (err instanceof Anthropic.APIError) {
          throw Object.assign(new Error(`generation provider error (${err.status ?? 'network'})`), { statusCode: 502 });
        }
        throw err;
      }
      // Säkerhetsklassificerarna kan avböja (HTTP 200, stop_reason 'refusal') —
      // hanteras ärligt som otillgängligt förslag, aldrig som tom text.
      if (response.stop_reason === 'refusal') {
        throw Object.assign(new Error('generation provider declined the request'), { statusCode: 502 });
      }
      const text = response.content.find((c): c is Anthropic.TextBlock => c.type === 'text')?.text ?? '';
      let parsed: { improved?: string; reason?: string };
      try {
        parsed = JSON.parse(text) as { improved?: string; reason?: string };
      } catch {
        throw Object.assign(new Error('generation provider returned malformed suggestion'), { statusCode: 502 });
      }
      if (typeof parsed.improved !== 'string' || typeof parsed.reason !== 'string') {
        throw Object.assign(new Error('generation provider returned malformed suggestion'), { statusCode: 502 });
      }
      return { after: parsed.improved, reason: parsed.reason };
    },
  };
}

export function activeGenerationProvider(): GenerationProvider | null {
  if (config.anthropicApiKey) return anthropicProvider(config.anthropicApiKey);
  if (config.generationMockEnabled) return mockProvider;
  return null;
}
