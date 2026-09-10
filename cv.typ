#import "@preview/modernpro-cv:2.1.0": *
#import "typst/modernpro-adapter.typ": (
  make-profile, render-awards, render-education, render-languages, render-simple-entries, render-skills, render-work,
)

#let data = json("data/cv.json")
#let cfg = data.at("x-typst", default: (:))
#let academic = data.at("x-academic", default: (:))
#let bib = academic.at("bibliography", default: (:))

#set text(
  font: (
    "Libertinus Serif",
    "Noto Serif KR",
    "Noto Serif CJK KR",
  ),
)

#show bibliography: set text(
  font: (
    "Libertinus Serif",
    "Noto Serif KR",
    "Noto Serif CJK KR",
  ),
)

#show: cv.with(
  profile: make-profile(data),
  theme: (
    accent: rgb(cfg.at("accent", default: "#00008B")),
  ),
  layout: (
    continue-header: cfg.at("continueHeader", default: true),
    contact-layout: cfg.at("contactLayout", default: "rail"),
  ),
  options: (
    last-updated: cfg.at("lastUpdated", default: true),
  ),
  preset: cfg.at("preset", default: "default"),
)

#section("Education")
#render-education(data.at("education", default: ()))
#section-gap

#section("Professional Experience")
#render-work(data.at("work", default: ()))
#section-gap

#section("Research Publications")
#publication(
  path(bib.at(
    "publications",
    default: "data/publications.bib",
  )),
  bib.at(
    "style",
    default: "elsevier-with-titles",
  ),
)
#section-gap

#section("Patents")
#bibliography(
  path(bib.at(
    "patents",
    default: "data/patents.bib",
  )),
  style: bib.at(
    "style",
    default: "elsevier-with-titles",
  ),
  title: none,
  full: true,
  group: none,
)
#section-gap

#section("Other Publications")
#render-simple-entries(academic.at("otherPublications", default: ()), "publisher")
#section-gap

#section("Awards")
#render-awards(data.at("awards", default: ()))
#section-gap

#section("Invited Talks")
#render-simple-entries(academic.at("invitedTalks", default: ()), "venue")
#section-gap

#section("Mentoring & Evaluation Activities")
#render-simple-entries(academic.at("activities", default: ()), "organization")
#section-gap

#section("Skills & Languages")
#render-skills(data.at("skills", default: ()))
#render-languages(data.at("languages", default: ()))
