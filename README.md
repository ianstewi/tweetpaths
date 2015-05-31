# Tweetpaths

Tweetpaths is a Twitter/Google Maps mashup written using Ruby on Rails. I currently have an implementation of this running at [tweetpaths.com][tweetpaths], but I will be shutting this down very soon. I have therefore decided to make the source code available for anyone who wishes to do their own implementation.

The code is probably not the greatest, it was written a while ago while I was learning Ruby on Rails. I'm not planning maintaining the code, I'm just making it available as it. Feel free to fork it and make your own improvements.

##Implementation

This section assumes you know how to deploy a Ruby on Rails application and so only covers some of the steps specific to Tweetpaths. [tweetpaths.com][tweetpaths] was originally hosted on Heroku, you may have to make some other changes if you host it elsewhere.

###Required Steps

There are two things you will need to do get the app up an running.

The first is to configure the consumer key and secret used by Twitter OAuth authentication. Create an application at [apps.twitter.com](https://apps.twitter.com). Take the consumer secret and key for the app and put them in **app/model/session.rb**.

The second thing is to set the secret token for Rails in the **config/secrets.yml** file.

###Optional Steps

There are a some other things you might want to do.

If you want to use Google Analytics, uncomment the relevant sections in **app/views/layouts/application.html.erb**, **app/views/layouts/mobile_application.html.erb**, **app/views/maps/add.js.erb** and **app/views/maps/add_error.js.erb**. You will need to add you own Google Analytics tracking ID.

You can set up Exception Notifier in **config/environments/production.rb**.

You will probably also want to update the **app/views/homes/about.html.erb** and **contact.html.erb** files. If you are using the icons in this repository, you should also keep the copyright notices for these icons.

##License

I have released this under the Apache License V2.0. See **LICENSE.txt** for the full license. As mentioned previously, if using the included icons, you should keep the copyright notices for these in the **about.html.erb** file.



[tweetpaths]: http://tweetpaths.com
