#lang racket/base

(require racket/contract
         racket/list
         racket/match
         json

         "urls.rkt"
         "fetcher.rkt")

(provide github/repos
         (struct-out repo)
         (struct-out owner))

(struct owner (avatar-url
                events-url
                followers-url
                following-url
                gists-url
                gravatar-id
                html-url
                id
                login
                organizations-url
                received-events-url
                repos-url
                site-admin
                starred-url
                subscriptions-url
                type
                url)
        #:transparent)

(struct repo (archive-url
               assignees-url
               blobs-url
               branches-url
               clone-url
               collaborators-url
               comments-url
               commits-url
               compare-url
               contents-url
               contributors-url
               created-at
               default-branch
               description
               downloads-url
               events-url
               fork
               forks
               forks-count
               forks-url
               full-name
               git-commits-url
               git-refs-url
               git-tags-url
               git-url
               has-downloads
               has-issues
               has-pages
               has-wiki
               homepage
               hooks-url
               html-url
               id
               issue-comment-url
               issue-events-url
               issues-url
               keys-url
               labels-url
               language
               languages-url
               merges-url
               milestones-url
               mirror-url
               name
               notifications-url
               open-issues
               open-issues-count
               owner
               private
               pulls-url
               pushed-at
               releases-url
               size
               ssh-url
               stargazers-count
               stargazers-url
               statuses-url
               subscribers-url
               subscription-url
               svn-url
               tags-url
               teams-url
               trees-url
               updated-at
               url
               watchers
               watchers-count)
        #:transparent)

(define/contract (github/repos login
                               #:token [token ""])
  ((string?) (#:token string?) . ->* . (listof repo?))

  (define/contract (js-repo->repo js-repo)
    (jsexpr? . -> . repo?)

    (match js-repo
      [(hash-table
         ('archive_url archive-url)
         ('assignees_url assignees-url)
         ('blobs_url blobs-url)
         ('branches_url branches-url)
         ('clone_url clone-url)
         ('collaborators_url collaborators-url)
         ('comments_url comments-url)
         ('commits_url commits-url)
         ('compare_url compare-url)
         ('contents_url contents-url)
         ('contributors_url contributors-url)
         ('created_at created-at)
         ('default_branch default-branch)
         ('description description)
         ('downloads_url downloads-url)
         ('events_url events-url)
         ('fork fork)
         ('forks forks)
         ('forks_count forks-count)
         ('forks_url forks-url)
         ('full_name full-name)
         ('git_commits_url git-commits-url)
         ('git_refs_url git-refs-url)
         ('git_tags_url git-tags-url)
         ('git_url git-url)
         ('has_downloads has-downloads)
         ('has_issues has-issues)
         ('has_pages has-pages)
         ('has_wiki has-wiki)
         ('homepage homepage)
         ('hooks_url hooks-url)
         ('html_url html-url)
         ('id id)
         ('issue_comment_url issue-comment-url)
         ('issue_events_url issue-events-url)
         ('issues_url issues-url)
         ('keys_url keys-url)
         ('labels_url labels-url)
         ('language language)
         ('languages_url languages-url)
         ('merges_url merges-url)
         ('milestones_url milestones-url)
         ('mirror_url mirror-url)
         ('name name)
         ('notifications_url notifications-url)
         ('open_issues open-issues)
         ('open_issues_count open-issues-count)
         ('owner
          (hash-table
            ('avatar_url avatar-url)
            ('events_url owner-events-url)
            ('followers_url followers-url)
            ('following_url following-url)
            ('gists_url gists-url)
            ('gravatar_id gravatar-id)
            ('html_url owner-html-url)
            ('id owner-id)
            ('login login)
            ('organizations_url organizations-url)
            ('received_events_url received-events-url)
            ('repos_url repos-url)
            ('site_admin site-admin)
            ('starred_url starred-url)
            ('subscriptions_url subscriptions-url)
            ('type type)
            ('url owner-url)))
         ('private private)
         ('pulls_url pulls-url)
         ('pushed_at pushed-at)
         ('releases_url releases-url)
         ('size size)
         ('ssh_url ssh-url)
         ('stargazers_count stargazers-count)
         ('stargazers_url stargazers-url)
         ('statuses_url statuses-url)
         ('subscribers_url subscribers-url)
         ('subscription_url subscription-url)
         ('svn_url svn-url)
         ('tags_url tags-url)
         ('teams_url teams-url)
         ('trees_url trees-url)
         ('updated_at updated-at)
         ('url url)
         ('watchers watchers)
         ('watchers_count watchers-count))
       (repo
         archive-url
         assignees-url
         blobs-url
         branches-url
         clone-url
         collaborators-url
         comments-url
         commits-url
         compare-url
         contents-url
         contributors-url
         created-at
         default-branch
         description
         downloads-url
         events-url
         fork
         forks
         forks-count
         forks-url
         full-name
         git-commits-url
         git-refs-url
         git-tags-url
         git-url
         has-downloads
         has-issues
         has-pages
         has-wiki
         homepage
         hooks-url
         html-url
         id
         issue-comment-url
         issue-events-url
         issues-url
         keys-url
         labels-url
         language
         languages-url
         merges-url
         milestones-url
         mirror-url
         name
         notifications-url
         open-issues
         open-issues-count
         (owner
           avatar-url
           owner-events-url
           followers-url
           following-url
           gists-url
           gravatar-id
           owner-html-url
           owner-id
           login
           organizations-url
           received-events-url
           repos-url
           site-admin
           starred-url
           subscriptions-url
           type
           owner-url)
         private
         pulls-url
         pushed-at
         releases-url
         size
         ssh-url
         stargazers-count
         stargazers-url
         statuses-url
         subscribers-url
         subscription-url
         svn-url
         tags-url
         teams-url
         trees-url
         updated-at
         url
         watchers
         watchers-count)]))

  (map js-repo->repo
       (github/fetch (compose-repos-url login)
                     #:token token)))


(module+ main
  (require racket/pretty
           "token.rkt")

  (pretty-print (map repo-owner (github/repos "GoNZooo"))))
