/**
 * Behöver stödet någon ansökan alls?
 *
 * Vissa stöd i kunskapsbasen kräver ingen ansökan — de dras automatiskt
 * (allmänt tandvårdsbidrag) eller registreras i regionens system
 * (högkostnadsskydd). Att sälja en "förberedd ansökan" för ett sådant stöd
 * vore att ta betalt för ingenting (UX-genomgången 2026-09-02, F-INGEN-ANSÖKAN).
 *
 * Sanningen ligger i det kurerade fältet applicationMethod på SVENSKA
 * (seedens källspråk, före översättning): kuratorn skriver "Ingen ansökan — …"
 * exakt när myndigheten säger att ingen ansökan behövs. Regeln härleds ur den
 * texten och hittar aldrig på något eget.
 */
export function requiresApplication(applicationMethod: string | null | undefined): boolean {
  return !/^\s*ingen ansökan\b/i.test(applicationMethod ?? '');
}
