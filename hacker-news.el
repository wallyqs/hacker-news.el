;; hacker-news.el
;; December 12th 2009
;; "Elisp for reading hacker-news on emacs"
;; Links are opened by Firefox
;; Too much regular expressions for scraping... parsing is done the Ctulhu way
;;; Author: Waldemar Quevedo - invertedplate (at) gmail.com
;;;
;;; Copyright: This code is in the public domain.

(defun hacker-news()
  (interactive)
  (let ((url-request-method "GET"))
    (url-retrieve
     "http://news.ycombinator.com/"
     '(lambda (status)
        (with-current-buffer (current-buffer)
          ;;  TITLE
          (re-search-forward "\<td class=\"title\"" nil t)
          (setq inicio (match-beginning 0))

          ;; LAST TITLE
          (re-search-forward "\<td class=\"title\"" nil t 29)

          ;; LAST TITLE COMMENT
          (re-search-forward "\<tr" nil t)
          (re-search-forward "tr\>" nil t)

          (setq final (match-end 0))

          (setq content
                (buffer-substring-no-properties inicio final))

          (setq hashy (make-hash-table :test 'equal))
          (with-temp-buffer
            (insert "\n" content)
            (goto-char (point-min))

            (while (re-search-forward "\<td class=\"title\"" nil t)
              ;; titles...
              (re-search-forward "\<a" nil t)
              (setq anchor-start (match-beginning 0))

              ;;  links...
              (re-search-forward "href=\"" nil t)
              (setq link-start (match-end 0))
              (re-search-forward "\"")
              (setq link-end (match-beginning 0))

              (setq title-link
                    (buffer-substring-no-properties link-start link-end))

              ;; go back for the titles
              (re-search-forward "\>" nil t)
              (setq iinicio (match-end 0))

              (re-search-forward "\<\/a\>" nil t)
              (setq ffinal (match-beginning 0))

              (setq titulo
                    (buffer-substring-no-properties iinicio ffinal))
	      
              (puthash titulo title-link hashy)

              )
            )          
          )
        (kill-buffer (current-buffer))
	;; (pp hashy)

	;; FIXME: This looks dumb
	(get-buffer-create "Hacker News")
	(set-buffer "Hacker News")
	(kill-buffer "Hacker News")
	(get-buffer-create "Hacker News")
	(set-buffer "Hacker News")
	;; t: titulo, l: link

	(setq articles-counter 0)
	(maphash (lambda(ti li) 
		   (setq articles-counter 
			 (1+ articles-counter))
		   (setq articles-counter-s (number-to-string articles-counter))
		   (insert articles-counter-s ".- " ti )
		   (insert "\n")
		   (insert li "\n")

		   ;; FIXME: How to add a parameter to a button?
		   (insert-button "Go"
				  'action '(lambda (button)
					     (re-search-backward "http")
					     (setq address-start (match-beginning 0))
					     (goto-char address-start)
					     (re-search-forward "^http.*?$" nil t)
					     (setq address-end (match-end 0))
					     (setq address (buffer-substring-no-properties address-start address-end))
					     (browse-url-firefox address)
					     (pp address)
					    ))
		   (insert "\n\n")
		   ) hashy)
	(set-window-buffer (next-window) "Hacker News")
	(goto-char (point-min))
        )
     )
    )
  )

(provide 'hacker-news)