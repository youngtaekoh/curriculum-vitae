#import "@preview/modernpro-cv:2.1.0": *

#let _get(obj, key, default: none) = obj.at(key, default: default)

#let _content(value) = if value == none { none } else { [#value] }

#let _fmt-date(value) = {
  if value == none or value == "" { return none }
  let parts = value.split("-")
  if parts.len() == 1 { value }
  else if parts.len() >= 2 { parts.at(0) + "." + parts.at(1) }
  else { value }
}

#let _date-range(item) = {
  let start = _fmt-date(_get(item, "startDate"))
  let end = _fmt-date(_get(item, "endDate"))
  if start == none { none }
  else if end == none { start + "–Present" }
  else { start + "–" + end }
}

#let _labeled(item) = {
  if type(item) == str { [#item] }
  else {
    let label = _get(item, "label")
    let text = _get(item, "text", default: "")
    if label == none { [#text] }
    else { [#strong(label + ":") #text] }
  }
}

#let _details(items) = {
  if items == none or items.len() == 0 { none }
  else { list(..items.map(_labeled)) }
}

#let _highlight(item) = {
  if type(item) == str { [#item] }
  else if _get(item, "children") != none {
    let text = _get(item, "text", default: "")
    let children = _get(item, "children", default: ())
    [#strong(text) #list(..children.map(_labeled))]
  } else {
    _labeled(item)
  }
}

#let _highlights(items) = {
  if items == none or items.len() == 0 { none }
  else { list(..items.map(_highlight)) }
}

#let make-profile(data) = {
  let basics = _get(data, "basics", default: (:))
  let cfg = _get(data, "x-typst", default: (:))
  let contacts = ()

  let email = _get(basics, "email")
  if email != none and email != "" {
    contacts.push((text: [#email], link: "mailto:" + email))
  }

  let url = _get(basics, "url")
  if url != none and url != "" {
    let label = url.replace("https://", "").replace("http://", "").trim("/")
    contacts.push((text: [#label], link: url))
  }

  for p in _get(basics, "profiles", default: ()) {
    let network = _get(p, "network", default: "")
    let username = _get(p, "username", default: "")
    let label = if network == "" { username } else { network + " " + username }
    let link = _get(p, "url")
    if link == none { contacts.push([#label]) }
    else { contacts.push((text: [#label], link: link)) }
  }

  let location = _get(basics, "location", default: (:))
  let address = _get(location, "x-display")

  let photo-path = _get(basics, "image")
  let show-picture = _get(cfg, "showPicture", default: true)
  let photo = if show-picture and photo-path != none and photo-path != "" {
    image(
      photo-path,
      width: 16mm,
      height: 20mm,
      fit: "cover",
    )
  } else {
    none
  }

  (
    name: _content(_get(basics, "name", default: "")),
    role: _content(_get(basics, "label", default: "")),
    address: _content(address),
    photo: photo,
    contacts: contacts,
  )
}

#let render-education(items) = {
  for item in items {
    let degree = _get(item, "studyType", default: "")
    let area = _get(item, "area", default: "")
    let major = if degree == "" { area } else if area == "" { degree } else { degree + ", " + area }
    education(
      institution: _content(_get(item, "institution", default: "")),
      major: _content(major),
      date: _date-range(item),
      description: _details(_get(item, "x-details", default: ())),
    )
  }
}

#let render-work(items) = {
  for item in items {
    let position = _get(item, "position", default: "")
    let company = _get(item, "name", default: "")
    let title = if position == "" { company } else { position }
    let institution = if position == "" { none } else { _content(company) }
    experience(
      title: title,
      institution: institution,
      location: _get(item, "location"),
      date: _date-range(item),
      details: _highlights(_get(item, "highlights", default: ())),
    )
  }
}

#let render-awards(items) = {
  for item in items {
    award(
      award: _content(_get(item, "title", default: "")),
      institution: _content(_get(item, "awarder")),
      date: _get(item, "date"),
    )
  }
}

#let render-simple-entries(items, meta-key) = {
  for item in items {
    entry(
      title: _content(_get(item, "name", default: "")),
      right: _get(item, "date"),
      meta: _content(_get(item, meta-key)),
    )
  }
}

#let render-skills(items) = {
  for item in items {
    detail-line(
      title: _get(item, "name", default: ""),
      content: _content(_get(item, "keywords", default: ()).join(", ")),
    )
  }
}

#let render-languages(items) = {
  for item in items {
    detail-line(
      title: _get(item, "language", default: ""),
      content: _content(_get(item, "fluency", default: "")),
    )
  }
}
