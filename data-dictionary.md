# Main risk database

| Field | Description |
|----|----|
| `Title` | Paper's title |
| `QuickRef` | Paper's short ref |
| `Ev_ID` | Uniquely identifies a *row* in the main database table (but not necessarily a unique 'object' - e.g. where there is additional evidence, the first piece cohabitates with the risk category/sub-category description) |
| `Paper_ID` | Paper's unique ID (looks stable / chronological, e.g. not re-alphabetised in new versions) |
| `Cat_ID` | WITHIN a paper, uniquely identifies a risk category |
| `SubCat_ID` | WITHIN a paper-category, uniquely identifies a risk subcategory |
| `AddEv_ID` | WITHIN a paper-category-subcategory, uniquely identifies a piece of additional evidence EXCEPT the first (which colocates with the description) |
| `Category Level` | The nature of the row (i.e. the dimension for dimensional modelling) |
| `Risk category` | A risk category |
| `Risk subcategory` | A risk subcategory |
| `Description` | Description of a paper-category or paper-category-subcategory |
| `Additional ev.` | Extra evidence for a category or subcategory |
| `P.Def` | Page of a paper that a definition is found on |
| `p.AddEv` | Page of a paper where a piece of additional evidence is |
| `Entity` | Part of the High-Level Causal Taxonomy. Relates to a paper-category-subcategory. |
| `Intent` | " " |
| `Timing` | " " |
| `Domain` | Part of the Mid-Level Domain Taxonomy. Relates to a paper-category-subcategory. |
| `Sub-domain` | " " |

# Included papers table

TODO
