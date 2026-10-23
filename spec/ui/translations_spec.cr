# SPDX-License-Identifier: AGPL-3.0-or-later

require "../spec_helper"

# Traductions des écrans de l'extension (ADR-005 D7) : chaque route de
# `/ext/ESALINK/` servie en `GET` (liste tirée du routeur de Marten),
# obtenue dans chaque langue de l'interface (`Partiduo::LOCALES`) par un
# administrateur, EsaLink d'abord non raccordé, puis raccordé en
# préproduction. Contrôle de l'interface (`PartiduoUi::Translations`) : ni
# marqueur de traduction absente, ni clé brute, ni interpolation non
# résolue, et toute route atteinte par les liens des pages.

private alias S = Esalink::SpecSupport

describe "Traductions des écrans EsaLink (chaque langue de l'interface)" do
  it "rend chaque écran dans chaque langue, sans clé absente, brute ni interpolation non résolue" do
    S.books
    browser = PartiduoUi::Accounts.signed_in
    explorer = PartiduoUi::Translations::Explorer.new(&.name.starts_with?("esalink:"))
    explorer.crawl(browser, "ESALINK non raccordé")
    S.connect
    explorer.crawl(browser, "ESALINK raccordé")
    puts "\nTraductions de ESALINK : #{explorer.report}"
    (explorer.failures + explorer.unreached.map { |route| "route jamais atteinte : #{route}" }).should eq([] of String)
  ensure
    # L'exploration laisse active la dernière langue demandée : les
    # exemples suivants attendent la langue par défaut.
    I18n.activate(Marten.settings.i18n.default_locale)
  end
end
