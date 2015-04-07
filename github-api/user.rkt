#lang racket/base

(require racket/contract
		 racket/match
		 json

		 "urls.rkt"
		 "fetcher.rkt")

(provide github/user
		 (struct-out user))

(struct user (avatar-url
			   bio
			   blog
			   company
			   created-at
			   email
			   events-url
			   followers
			   followers-url
			   following
			   following-url
			   gists-url
			   gravatar-id
			   hireable
			   html-url
			   id
			   location
			   login
			   name
			   organizations-url
			   public-gists
			   public-repos
			   received-events-url
			   repos-url
			   site-admin
			   starred-url
			   subscriptions-url
			   type
			   updated-at
			   url)
		#:transparent)

(define/contract (github/user login
							  #:token [token ""])
  ((string?) (#:token string?) . ->* . (or/c user? list? jsexpr?))

  (match (github/fetch (compose-user-url login)
					#:token token)
	[(hash-table
	   ('avatar_url avatar-url)
	   ('bio bio)
	   ('blog blog)
	   ('company company)
	   ('created_at created-at)
	   ('email email)
	   ('events_url events-url)
	   ('followers followers)
	   ('followers_url followers-url)
	   ('following following)
	   ('following_url following-url)
	   ('gists_url gists-url)
	   ('gravatar_id gravatar-id)
	   ('hireable hireable)
	   ('html_url html-url)
	   ('id id)
	   ('location location)
	   ('login login)
	   ('name name)
	   ('organizations_url organizations-url)
	   ('public_gists public-gists)
	   ('public_repos public-repos)
	   ('received_events_url received-events-url)
	   ('repos_url repos-url)
	   ('site_admin site-admin)
	   ('starred_url starred-url)
	   ('subscriptions_url subscriptions-url)
	   ('type type)
	   ('updated_at updated-at)
	   ('url url))
	 (user avatar-url
		   bio
		   blog
		   company
		   created-at
		   email
		   events-url
		   followers
		   followers-url
		   following
		   following-url
		   gists-url
		   gravatar-id
		   hireable
		   html-url
		   id
		   location
		   login
		   name
		   organizations-url
		   public-gists
		   public-repos
		   received-events-url
		   repos-url
		   site-admin
		   starred-url
		   subscriptions-url
		   type
		   updated-at
		   url)]))

(module+ main
  (require racket/pretty
		   "token.rkt")

  (pretty-print (github/user "GoNZooo")))
