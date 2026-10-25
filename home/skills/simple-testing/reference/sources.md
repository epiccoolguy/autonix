# Sources

Each bracketed tag in this skill maps to one entry below. Read this file when asked why a rule exists or to justify one in a decision record. DDIA tags use 1st-edition chapter titles; the 2nd edition (Kleppmann and Riccomini) reorganizes chapters, so check titles there.

## Core library

| Tag | Source | Used for |
| --- | --- | --- |
| Ousterhout: Modules Should Be Deep | Ousterhout, *A Philosophy of Software Design*, 2nd ed., ch. "Modules Should Be Deep" | Small interfaces are what tests go through |
| Ousterhout: Software Trends | same, ch. "Software Trends" (test-driven development) | Unit tests enable refactoring; test first when fixing a bug, not as dogma |
| Evans: Published Language | Evans, *Domain-Driven Design*, ch. "Maintaining Model Integrity" | A boundary contract is a deliberately designed model |
| Fowler: Building Tests | Fowler, *Refactoring*, 2nd ed., ch. 4 | Self-testing code; fresh fixture per test |
| Bentley: Writing Correct Programs | Bentley, *Programming Pearls*, 2nd ed., column 4 | Invariants and assertions |
| DDIA: Encoding and Evolution | Kleppmann, *Designing Data-Intensive Applications* | Backward and forward compatibility; old and new code share data |
| DDIA: Transactions | same | Isolation and locking differ between engines |
| DDIA: The Trouble with Distributed Systems | same | Unreliable clocks |
| DDIA: Consistency and Consensus | same | Checking histories against a consistency model |
| Pragmatic: Property-Based Testing | Thomas and Hunt, *The Pragmatic Programmer*, 20th anniv. ed., "Property-Based Testing" | Generated inputs test assumptions |
| Pragmatic: Pragmatic Starter Kit | same, "Pragmatic Starter Kit" | Test early and automatically; find bugs once; use saboteurs to test your testing; test state coverage, not code coverage |
| Brooks: Passing the Word | Brooks, *The Mythical Man-Month*, anniv. ed., ch. 6 | Precise, formal interface definitions |

## Testing

| Tag | Source |
| --- | --- |
| Beck: Test Desiderata | Kent Beck, "Test Desiderata", 2019 (structure-insensitive tests); *Test-Driven Development: By Example*, 2002 |
| Meszaros: Test Double, Fresh Fixture, Test Smells | Meszaros, *xUnit Test Patterns*, 2007 (dummy, stub, spy, mock, fake; Mystery Guest, General Fixture) |
| GOOS: Only Mock Types You Own, Test Data Builders | Freeman and Pryce, *Growing Object-Oriented Software, Guided by Tests*, 2009 |
| Khorikov: Coverage | Khorikov, *Unit Testing Principles, Practices, and Patterns*, 2020, ch. 1 |
| Khorikov: Four Pillars | same, ch. 4 |
| Khorikov: Observable Behavior | same, ch. 2 and 5 (classical school; observable behavior vs implementation details) |
| Khorikov: Unmanaged Dependencies | same, ch. 8 and 9 (mocks only for dependencies other systems observe) |
| Khorikov: Database Testing | same, ch. 10 |
| Khorikov: Working with Time | same, ch. 11 (time as an injected dependency, not an ambient context) |
| Feathers: Seams | Feathers, *Working Effectively with Legacy Code*, 2004 |
| SWE at Google: Testing Overview | Winters, Manshreck, Wright, *Software Engineering at Google*, 2020, ch. 11 (test sizes and scope) |
| SWE at Google: Unit Testing | same, ch. 12 (test via public APIs; descriptive and meaningful phrases over DRY) |
| SWE at Google: Test Doubles | same, ch. 13 (real, then fake, then stub; fakes kept faithful) |
| SWE at Google: Larger Testing | same, ch. 14 |
| SWE at Google: Continuous Integration | same, ch. 23 |
| Fowler: Mocks Aren't Stubs | martinfowler.com, 2007 (classical vs mockist) |
| Fowler: Practical Test Pyramid | Ham Vocke, martinfowler.com, 2018 (after Cohn, *Succeeding with Agile*, 2009) |
| Fowler: Shapes of Testing | Fowler, "On the Diverse And Fantastical Shapes of Testing", 2021 |
| Fowler: IntegrationTest | martinfowler.com/bliki, 2018 (narrow vs broad) |
| Fowler: ContractTest | martinfowler.com/bliki, 2011 |
| Fowler: TolerantReader | martinfowler.com/bliki, 2011 |
| Fowler: Consumer-Driven Contracts | Ian Robinson, martinfowler.com, 2006 |
| Fowler: Eradicating Non-Determinism | martinfowler.com, 2011 (quarantine; causes of non-determinism) |
| Fowler: TestCoverage | martinfowler.com/bliki, 2012 |
| Fowler: Continuous Integration | martinfowler.com, 2024 revision (ten-minute build) |
| Fowler: Evolutionary Database Design | Fowler and Sadalage, martinfowler.com, 2003, revised 2016 |
| Dodds: Testing Trophy | Kent C. Dodds, "Write tests. Not too many. Mostly integration.", 2017; "The Testing Trophy and Testing Classifications", 2021 |
| Spotify: Testing Honeycomb | Andre Schaffer, "Testing of Microservices", Spotify Engineering, 2018 |
| Hughes: QuickCheck | Claessen and Hughes, "QuickCheck", ICFP 2000 |
| Hughes: How to Specify It | John Hughes, "How to Specify It!", 2019 |
| Hypothesis | David MacIver et al., hypothesis.works (shrinking, stateful testing) |
| Go: Fuzzing | go.dev/doc/security/fuzz (native fuzzing since Go 1.18) |
| Google: Mutation Testing | Petrovic and Ivankovic, "State of Mutation Testing at Google", ICSE-SEIP 2018 |
| Google: Code Coverage Best Practices | Arguelles, Ivankovic, Bender, Google Testing Blog, 2020 |
| Luo: Flaky Tests | Luo et al., "An Empirical Analysis of Flaky Tests", FSE 2014 |
| Sridharan: Testing in Production | Cindy Sridharan, "Testing in Production, the safe way", 2018 |
| Google SRE: Testing for Reliability | Beyer et al., *Site Reliability Engineering*, 2016, ch. 17 |
| Google SRE: Data Integrity | same, ch. 26 ("What You Read Is What You Wrote") |
| Humble and Farley: Continuous Delivery | Humble and Farley, *Continuous Delivery*, 2010 (commit stage) |
| Sadalage and Ambler: Refactoring Databases | Ambler and Sadalage, *Refactoring Databases*, 2006 (transition period) |
| GitLab: 2017 Outage | GitLab, "Postmortem of database outage of January 31", 2017 |
