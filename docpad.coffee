# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
docpadConfig =

	# =================================
	# Template Data
	# These are variables that will be accessible via our templates
	# To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

	templateData:

		# Specify some site properties
		site:
			# The production url of our website
			# If not set, will default to the calculated site URL (e.g. http://localhost:9778)
			url: "http://jsconfbp.com"

			# Here are some old site urls that you would like to redirect from
			oldUrls: [
			]

			# The default title of our website
			title: "JSConf Budapest 2016, May 12-13."

			# The website description (for SEO)
			description: """
				JSConf Budapest is coming again! May 12-13, 2016, Budapest, Hungary
				"""

			socialImage: "http://jsconfbp.com/images/og_image.jpg"

			# The website keywords (for SEO) separated by commas
			keywords: """
				jsconf, javascript, jsconfbp, conference, budapest, jsconf budapest
				"""

			# The website's styles
			styles: [
				'/vendor/normalize.css'
				'/vendor/h5bp.css'
				'/styles/index.css'
			]

			# The website's scripts
			scripts: [
				"""
				<!-- jQuery -->
				<script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"></script>
				<script>window.jQuery || document.write('<script src="/vendor/jquery.js"><\\/script>')</script>
				"""

				'/vendor/log.js'
				'/vendor/modernizr.js'
				'/vendor/paper-full-min.js'
				'/scripts/script.js'
			]


		# -----------------------------
		# Helper Functions
		getUrl: (document) ->
			return @site.url + (document.url or document.get?('url'))

		# Get the prepared site/document title
		# Often we would like to specify particular formatting to our page's title
		# we can apply that formatting here
		getPreparedTitle: ->
			# if we have a document title, then we should use that and suffix the site's title onto it
			if @document.title
				"#{@document.title} | #{@site.title}"
			# if our document does not have it's own title, then we should just use the site's title
			else
				@site.title

		getSiteTitle: ->
			@site.title

		# Get the prepared site/document description
		getPreparedDescription: ->
			# if we have a document description, then we should use that, otherwise use the site's description
			@document.description or @document.lead or @site.description

		# Get the prepared site/document keywords
		getPreparedKeywords: ->
			# Merge the document keywords with the site keywords
			@site.keywords.concat(@document.keywords or []).join(', ')

		getSocialShareImage: ->
			# if we have a document title, then we should use that and suffix the site's title onto it
			if @document.socialImage
				@document.socialImage
			# if our document does not have it's own title, then we should just use the site's title
			else
				@site.socialImage

		getSpeakerTwitter: (page) ->
			if page.twitter1? && page.twitter2?
				"""
					<a href=\"https://twitter.com/#{page.twitter1.replace('@', '')}\" class=\"twitter\">#{page.twitter1}</a>
					<a href=\"https://twitter.com/#{page.twitter2.replace('@', '')}\" class=\"twitter\">#{page.twitter2}</a>
				"""
			else
				"""
					<a href=\"https://twitter.com/#{page.twitter.replace('@', '')}\" class=\"twitter\">#{page.twitter}</a>
				"""

		getSpeakerImageSrc: (page) ->
			if page.twitter1? && page.twitter2?
				"/images/speaker-#{page.twitter1.replace('@', '').toLowerCase()}-#{page.twitter2.replace('@', '').toLowerCase()}.jpg"
			else
				"/images/speaker-#{page.twitter.replace('@', '').toLowerCase()}.jpg"

	# =================================
	# Collections

	# Here we define our custom collections
	# What we do is we use findAllLive to find a subset of documents from the parent collection
	# creating a live collection out of it
	# A live collection is a collection that constantly stays up to date
	# You can learn more about live collections and querying via
	# http://bevry.me/queryengine/guide

	collections:

		# Create a collection called posts
		# That contains all the documents that will be going to the out path posts
		news: ->
			@getCollection('documents').findAllLive({relativeOutDirPath: 'news'})

		speakers: ->
			@getCollection('documents').findAllLive({relativeOutDirPath: 'speakers'})

		mcs: ->
			@getCollection('documents').findAllLive({relativeOutDirPath: 'mcs'})
	# =================================
	# Environments

	# DocPad's default environment is the production environment
	# The development environment, actually extends from the production environment

	# The following overrides our production url in our development environment with false
	# This allows DocPad's to use it's own calculated site URL instead, due to the falsey value
	# This allows <%- @site.url %> in our template data to work correctly, regardless what environment we are in

	environments:
		development:
			templateData:
				site:
					url: false


	# =================================
	# DocPad Events

	# Here we can define handlers for events that DocPad fires
	# You can find a full listing of events on the DocPad Wiki

	events:

		# Server Extend
		# Used to add our own custom routes to the server before the docpad routes are added
		serverExtend: (opts) ->
			# Extract the server from the options
			{server} = opts
			docpad = @docpad

			# As we are now running in an event,
			# ensure we are using the latest copy of the docpad configuraiton
			# and fetch our urls from it
			latestConfig = docpad.getConfig()
			oldUrls = latestConfig.templateData.site.oldUrls or []
			newUrl = latestConfig.templateData.site.url

			# Redirect any requests accessing one of our sites oldUrls to the new site url
			server.use (req,res,next) ->
				if req.headers.host in oldUrls
					res.redirect(newUrl+req.url, 301)
				else
					next()


# Export our DocPad Configuration
module.exports = docpadConfig
