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
  'Svara ENBART med JSON: {"improved": "...", "reason": "..."} där reason på en mening sakligt beskriver vad som ändrades och varför.',
].join(' ');

function anthropicProvider(apiKey: string): GenerationProvider {
  return {
    id: 'anthropic',
    async suggest({ fieldLabel, guidance, before }) {
      const res = await fetch('https://api.anthropic.com/v1/messages', {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: JSON.stringify({
          model: 'claude-sonnet-5',
          max_tokens: 1024,
          system: SYSTEM_PROMPT,
          messages: [
            {
              role: 'user',
              content: `Fält: ${fieldLabel}\n${guidance ? `Fältets vägledning: ${guidance}\n` : ''}Sökandens text:\n"""\n${before}\n"""`,
            },
          ],
        }),
      });
      if (!res.ok) {
        throw Object.assign(new Error(`generation provider error (${res.status})`), { statusCode: 502 });
      }
      const body = (await res.json()) as { content?: { type: string; text?: string }[] };
      const text = body.content?.find((c) => c.type === 'text')?.text ?? '';
      const parsed = JSON.parse(text) as { improved?: string; reason?: string };
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
