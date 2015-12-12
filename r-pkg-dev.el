;;; r-pkg-dev.el --- Minor mode to facilitate R package development

;; Copyright (C) 2015  Stefan Widgren

;; Author: Stefan Widgren <stefan.widgren@gmail.com>
;; Keywords: R

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This file provides `r-pkg-dev-mode', a minor mode for R package
;; development.

;;; Code:

(defun r-pkg-dev-package-version ()
  "Determine package version from DESCRIPTION file."
  (interactive)
  (message (shell-command-to-string
            "Rscript -e 'cat(read.dcf(\"DESCRIPTION\")[1, \"Version\"])'")))

(defun r-pkg-dev-package-name ()
  "Determine package name from DESCRIPTION file."
  (interactive)
  (message (shell-command-to-string
            "Rscript -e 'cat(read.dcf(\"DESCRIPTION\")[1, \"Package\"])'")))

(defun r-pkg-dev-package-tar ()
  (interactive)
  (message (format "%s_%s.tar.gz"
                   (r-pkg-dev-package-name)
                   (r-pkg-dev-package-version))))

(defun r-pkg-dev-roxygen-version ()
  "Determine version of installed roxygen2 package."
  (interactive)
  (message (shell-command-to-string
            "Rscript -e 'library(roxygen2); cat(as.character(packageVersion(\"roxygen2\")))'")))

(defun r-pkg-dev-install-package ()
  "Install R package."
  (interactive)
  (with-output-to-temp-buffer "*install-package*"
    (shell-command (format "cd .. && R CMD INSTALL %s &"
                           (r-pkg-dev-package-name))
                   "*install-package*"
                   "*Messages*")
    (pop-to-buffer "*install-package*")))

(defun r-pkg-dev-check-package ()
  "Check R package."
  (interactive)
  (with-output-to-temp-buffer "*check-package*"
    (shell-command (format "cd .. && R CMD build --no-build-vignettes %s && _R_CHECK_CRAN_INCOMING_=FALSE NOT_CRAN=true R CMD check --as-cran --no-manual --no-vignettes --no-build-vignettes %s &"
                           (r-pkg-dev-package-name)
                           (r-pkg-dev-package-tar))
                   "*check-package*"
                   "*Messages*")
    (pop-to-buffer "*check-package*")))

(defun r-pkg-dev-install ()
  (interactive)
  (with-output-to-temp-buffer "*install-package*"
    (shell-command (format "cd .. && R CMD INSTALL %s &"
                           (r-pkg-dev-package-name))
                   "*install-package*"
                   "*Messages*")
    (pop-to-buffer "*install-package*")))

(defun r-pkg-dev-roxygenize ()
  "Roxygenize package documentation documentation"
  (interactive)
  (with-output-to-temp-buffer "*roxygenize-package*"
    (call-process
     "Rscript" nil "*roxygenize-package*" t
     "-e" "library(roxygen2)"
     "-e" "man <- list.files(path = 'man', pattern = '[.]Rd$', full.names = TRUE)"
     "-e" "invisible(lapply(man, function(x) {cat(sprintf('Deleting: %s\\n', x)); unlink(x)}))"
     "-e" "cat('\\n')"
     "-e" "roxygenize()")
    (pop-to-buffer "*roxygenize-package*")))

(define-minor-mode r-pkg-dev-mode
  "Minor mode to facilitate R package development."
  :lighter " r-pkg-dev"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-c C-d n") 'r-pkg-dev-package-name)
            (define-key map (kbd "C-c C-d c") 'r-pkg-dev-check-package)
            (define-key map (kbd "C-c C-d i") 'r-pkg-dev-install-package)
            (define-key map (kbd "C-c C-d r") 'r-pkg-dev-roxygenize)
            (define-key map (kbd "C-c C-d v") 'r-pkg-dev-package-version)
            map))

(provide 'r-pkg-dev)
;;; r-pkg-dev.el ends here
