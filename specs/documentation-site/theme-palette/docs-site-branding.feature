@domain:documentation-site @area:theme-palette @from:docs/stylesheets
Feature: Branding the documentation site
  Gives people reading the rendered docs and the splash page one consistent, self-hosted look built from one pair of accent colours, so the project looks like one product and the docs work offline.

  Background:
    Given the documentation site is published with the splash page at the site root and the rendered docs under /docs/

  @id:documentation-site.theme-palette.001 @rule:docs.theme.single-accent-pair @inferred @source:docs/stylesheets/extra.css#:root
  Scenario Outline: One accent colour pair styles both the rendered docs and the splash page
    Given the project's accent pair is light blue #38bdf8 and blue #3b82f6
    When a reader opens <page>
    Then the <element> is drawn in <colouring>

    Examples:
      | page              | element               | colouring                          |
      | the rendered docs | theme primary colour  | blue #3b82f6                       |
      | the rendered docs | primary button        | a gradient from #38bdf8 to #3b82f6 |
      | the splash page   | project title         | a gradient from #38bdf8 to #3b82f6 |
      | the splash page   | GitHub button         | a gradient from #38bdf8 to #3b82f6 |

  @id:documentation-site.theme-palette.002 @rule:docs.theme.links-legible-per-scheme @inferred @source:docs/stylesheets/extra.css#[data-md-color-scheme="slate"]
  Scenario Outline: Links use the accent colour that stays readable in the active colour scheme
    Given the reader's docs colour scheme is <scheme>
    When a reader views a docs page containing a link
    Then the link is shown in <link colour>
    And the page background is <background>

    Examples:
      | scheme | link colour        | background                                          |
      | light  | blue #3b82f6       | the theme's default light background                |
      | dark   | light blue #38bdf8 | near-black #0b0f1a, also behind the header and tabs |

  @id:documentation-site.theme-palette.003 @rule:docs.theme.no-external-assets @inferred @source:docs/stylesheets/extra.css#:root
  Scenario: The docs load no fonts or styles from third-party servers
    When a reader opens the rendered docs or the splash page
    Then text is set in the operating system's own sans-serif font
    And code is set in the operating system's own monospace font
    And the browser requests no web font or stylesheet from another host

  @id:documentation-site.theme-palette.004 @rule:docs.branding.no-placeholder-logo @inferred @source:docs/stylesheets/extra.css#.md-header__button.md-logo
  Scenario: The docs header shows no stand-in logo while the project has none
    Given the docs site has no logo configured
    When a reader opens any docs page
    Then the header and the navigation title show no logo icon
    And the header shows the site name with no logo beside it
