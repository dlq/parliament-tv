# Future Open Parliamentary Streams Catalogue

A separate public catalogue could eventually document open parliamentary live-video and schedule access in a way that is useful beyond this app.

That repository would be different from this app:

- this app proves the viewer and surfability model;
- the catalogue would document source access, validation history, terms notes, and interoperability.

Possible repository shape:

```text
sources/
  canada/cpac.json
  canada/quebec-national-assembly.json
  new-zealand/parliament-tv.json

schemas/
  stream-source.schema.json
  schedule-source.schema.json

validation/
  latest.json
  history/
```

Useful fields:

- legislature or body name;
- jurisdiction;
- official page URL;
- stream URL or official embed URL;
- stream type: HLS, DASH, YouTube, official player, unknown;
- platform compatibility: AVPlayer, browser, YouTube app, etc.;
- schedule/EPG endpoint;
- caption and audio-language availability;
- legal/terms notes;
- attribution requirements;
- last verified date;
- validation result;
- known caveats.

Do not start this as the app's primary data source until the app model and source taxonomy are stable.
