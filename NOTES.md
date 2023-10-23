## Things missing from this implementation

There are several things I didn't really get around to implementing for this sample version of the application. These are things I'd definitely do for a more production worthy version.

### Testing

The app is completely untested at the moment. I typically like to at least write integration tests (e.g. make sure an API route is returning the expected JSON) before deploying.

### Performance

I spent basically no time optimizing performance. The sample version runs fine because there's so little data, but for a production version I'd want to revisit the database schema, create indexes, write a cursor based pagination algorithm, etc.

### Error handling

Error handling is pretty loose in the current version. I'm throwing lots of runtime errors and letting them break what they will. Preferably, there'd be a standard way of propagating errors from the backend to the frontend, probably as JSON.

### Styling

I left the frontend pretty bare bones, with just a bit of styling here and there for usability.

### More features

There are a ton of additional features that I'd want to add.

- Authentication system to control access.
- Better UI elements, such as search inputs with autocomplete, tooltips, graphs, and so on.
- More pages/components for viewing the data. Here are some options that come to mind.
  - A view for award information per recipient instead of per filing.
  - A view for overridden filings. It might be useful for users to see specifically what's changed between one filing and the next. 
