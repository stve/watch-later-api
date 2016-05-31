# Watch Later

Easily add YouTube videos to your Watch Later playlist from [Workflow](http://workflow.is)

## Configuration

### Setup on Google API access

1. Login to the [Google Developer Console](https://console.developers.google.com/apis/library) and create a new project
2. Enable the following APIs:
  * [YouTube Data API v3](https://console.developers.google.com/apis/api/youtube/overview)
  * [Google+ API](https://console.developers.google.com/apis/api/plus/overview)
  * [Contacts API](https://console.developers.google.com/apis/api/contacts/overview)

3. Create new credentials for your application (Follow the [yt gem's instructions](http://www.rubydoc.info/gems/yt#Configuring_your_app), you'll want to create an application that requires user interactions)
4. Store the client id and secret for deployment

### Deployment

The server requires 4 environment variables:

* `YT_CLIENT_ID` - Taken from step 4 above
* `YT_CLIENT_SECRET` - Also taken from step 4 above
* `RACK_COOKIE_SECRET` - A key you should keep secret
* `REDISTOGO_URL` - A URL to a redis server

#### Setup on Heroku



### Setup on Workflow

Add the [workflow]([https://workflow.is/workflows/7bf6f669b8074b0e905d9e49160281fd]) to your Workflow IOS app. At minimum, you'll want to adjust the `rootUrl` variable to point it to your web service location. The workflow is designed to run as an Action Extension. Typically I use it by sharing a YouTube URL (or shortlink) and invoking the Workflow from the share menu.

## Copyright

Copyright (c) 2016 Steve Agalloco. See [LICENSE](LICENSE.md) for details.
