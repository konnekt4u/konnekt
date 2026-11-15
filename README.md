# Konnekt

Static single-page website for the Konnekt creator network.

## Structure

- `index.html` — page shell and navigation
- `assets/styles.css` — responsive dark-and-gold styling
- `assets/app.js` — single-tab navigation, creator filters, Supabase auth, profiles, portfolios and project applications
- `supabase/migrations/20261115090000_creator_discovery_and_portfolios.sql` — additive database migration

## Supabase

The frontend uses the Supabase project URL and publishable key. A publishable key is intended for browser use; never put a service-role or secret key in frontend files.

Creator birth dates are stored in `creator_private_details`, a private table with owner-only RLS. The public creator directory only reads the selected age-range field on `profiles`.

## Creator discovery

Filters include talent, location, study year, experience, age range and specific skills. Creators may select multiple talents. Demo creator cards remain as fallback/sample content.

## Contact links

Gmail is configured to `konnekt4u@gmail.com`. Instagram links to `@konnekt4u`. WhatsApp currently uses a generic click-to-chat link; replace it with the official Konnekt WhatsApp number before launch.

## Local preview

Serve this folder with any static HTTP server. Do not open the HTML as a `file://` URL when testing Supabase authentication.
