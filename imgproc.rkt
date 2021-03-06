#lang racket

(require vigracket/config)
(require vigracket/helpers)
(require scheme/foreign)
(unsafe!)

;###############################################################################
;###################         Resize image                   ####################

(define vigra_resizeimage_c
  (get-ffi-obj 'vigra_resizeimage_c vigracket-dylib-path
               (_fun (img_vector1 img_vector2  width height width2 height2 resize_mode) :: [img_vector1 : _cvector]
                     [img_vector2 : _cvector]
                     [width : _int]
                     [height : _int]
                     [width2 : _int]
                     [height2 : _int]
                     [resize_mode : _int]
                     -> (res :  _int))))

(define (resizeimage-band  band width2 height2 [resize_mode 1])
  (let* ((width  (band-width  band))
	 (height (band-height band))
	 (band2  (make-band width2 height2 0.0))
	 (foo    (vigra_resizeimage_c (band-data band) (band-data band2) width height width2 height2 resize_mode)))
    (case foo
      ((0) band2)
      ((1) (error "Error in vigracket.imgproc:resizeimage: Resize of image failed!!"))
      ((2) (error "Error in vigracket.imgproc:resizeimage: Resize mode must be in {0,1,2,3,4}!!")))))

(define (resizeimage image width2 height2 [resize_mode 1])
  (map (lambda (band) (resizeimage-band band width2 height2 resize_mode)) image))
  

;###############################################################################
;###################         Rotate image                   ####################

(define vigra_rotateimage_c
  (get-ffi-obj 'vigra_rotateimage_c vigracket-dylib-path
               (_fun (img_vector1 img_vector2  width height angle resize_mode) :: [img_vector1 : _cvector]
                     [img_vector2 : _cvector]
                     [width : _int]
                     [height : _int]
                     [angle : _float*]
                     [resize_mode : _int]
                     -> (res :  _int))))

(define (rotateimage-band band angle [resize_mode 1])
  (let* ((width  (band-width  band))
	 (height (band-height band))
	 (band2   (make-band width height 0.0))
	 (foo   (vigra_rotateimage_c  (band-data band) (band-data band2) width height angle resize_mode)))
    (case foo
      ((0) band2)
      ((1) (error "Error in vigracket.imgproc:rotateimage: Rotation of image failed!!"))
      ((2) (error "Error in vigracket.imgproc:rotateimage: Resize mode must be in {0,1,2,3,4}!!")))))

(define (rotateimage image angle [resize_mode 1])
  (map (lambda (band) (rotateimage-band  band angle resize_mode)) image))

;###############################################################################
;###################         Affine transform image         ####################

(define vigra_affinewarpimage_c
  (get-ffi-obj 'vigra_affinewarpimage_c vigracket-dylib-path
               (_fun (img_vector1 img_vector2  affineMat width height resize_mode) :: [img_vector1 : _cvector]
                     [img_vector2 : _cvector]
                     [affineMat   : _cvector]
                     [width : _int]
                     [height : _int]
                     [resize_mode : _int]
                     -> (res :  _int))))

(define (affinewarpimage-band band affinematrix [resize_mode 1])
  (let* ((width  (band-width  band))
	 (height (band-height band))
	 (band2  (make-band width height 0.0))
	 (foo    (vigra_affinewarpimage_c (band-data band) (band-data band2) (matrix-data affinematrix) width height resize_mode)))
    (case foo
      ((0) band2)
      ((1) (error "Error in vigracket.imgproc:affinewarpimage: Affine Warp of image failed!!"))
      ((2) (error "Error in vigracket.imgproc:affinewarpimage: Resize mode must be in {0,1,2,3,4}!!")))))

(define (affinewarpimage image affinematrix [resize_mode 1])
  (map (lambda (band) (affinewarpimage-band band affinematrix resize_mode)) image))

  
;###############################################################################
;###################         Reflect image                  ####################

(define vigra_reflectimage_c
  (get-ffi-obj 'vigra_reflectimage_c vigracket-dylib-path
               (_fun (img_vector1 img_vector2  width height reflect_mode) :: [img_vector1 : _cvector]
                     [img_vector2 : _cvector]
                     [width : _int]
                     [height : _int]
                     [reflect_mode : _int]
                     -> (res :  _int))))

(define (reflectimage-band band reflect_mode)
  (let* ((width  (band-width  band))
	 (height (band-height band))
	 (band2  (make-band width height 0.0))
	 (foo    (vigra_reflectimage_c (band-data band) (band-data band2) width height reflect_mode)))
    (case foo
      ((0) band2)
      ((1) (error "Error in vigracket.imgproc:reflectimage: Reflection of image failed!!"))
      ((2) (error "Error in vigracket.imgproc:reflectimage: Reflection mode must be in {1 (= horizontal), 2 (= vertical), 3 (=both)}!!")))))
	  
	  
(define (reflectimage image reflect_mode)
  (map (lambda (band) (reflectimage-band band reflect_mode)) image))

;###############################################################################
;###################         Fast Fourier Transform         ####################

(define vigra_fouriertransform_c
  (get-ffi-obj 'vigra_fouriertransform_c vigracket-dylib-path
               (_fun (img_vector1 img_vector2   img_vector3  width height) :: [img_vector1 : _cvector]
                     [img_vector2 : _cvector]
                     [img_vector3 : _cvector]
                     [width : _int]
                     [height : _int]
                     -> (res :  _int))))

(define (fouriertransform-band band)
  (let* ((width  (band-width  band))
	 (height (band-height band))
	 (band2  (make-band width height 0.0))
	 (band3  (make-band width height 0.0))
	 (foo   (vigra_fouriertransform_c (band-data band)  (band-data band2) (band-data band3) width height)))
    (case foo
      ((0) (list band2 band3))
      ((1) (error "Error in vigracket.imgproc:fouriertransform: FastFourier Transform of image failed!!")))))


(define (fouriertransform image)
  (pivot-list (map fouriertransform-band image)))

;###############################################################################
;###################       Fast Cross Correlation           ####################

(define vigra_fastcrosscorrelation_c
  (get-ffi-obj 'vigra_fastcrosscorrelation_c vigracket-dylib-path
               (_fun (img_vector1 img_vector2 img_vector3 width height width2 height2) :: [img_vector1 : _cvector]
                     [img_vector2 : _cvector]
                     [img_vector3 : _cvector]
                     [width : _int]
                     [height : _int]
                     [width2 : _int]
                     [height2 : _int]
                     -> (res :  _int))))

(define (fastcrosscorrelation-band band mask_band)
  (let* ((width  (band-width  band))
         (height (band-height band))
         (mask_width  (band-width  mask_band))
         (mask_height (band-height mask_band))
         (band2  (make-band width height 0.0))
         (foo    (vigra_fastcrosscorrelation_c (band-data band) (band-data mask_band) (band-data band2) width height mask_width mask_height)))
    (case foo
      ((0) band2)
      ((1) (error "Error in vigracket.imgproc:fastcrosscorrelation: Fast cross-correlation of image failed!!"))
      ((2) (error "Error in vigracket.imgproc:fastcrosscorrelation: Mask width and height need to be odd!!")))))

(define (fastcrosscorrelation image mask)
  (map fastcrosscorrelation-band image mask))


;###############################################################################
;###################    Fast Normalized Cross Correlation   ####################

(define vigra_fastnormalizedcrosscorrelation_c
  (get-ffi-obj 'vigra_fastnormalizedcrosscorrelation_c vigracket-dylib-path
               (_fun (img_vector1 img_vector2 img_vector3 width height width2 height2) :: [img_vector1 : _cvector]
                     [img_vector2 : _cvector]
                     [img_vector3 : _cvector]
                     [width : _int]
                     [height : _int]
                     [width2 : _int]
                     [height2 : _int]
                     -> (res :  _int))))

(define (fastnormalizedcrosscorrelation-band band mask_band)
  (let* ((width  (band-width  band))
         (height (band-height band))
         (mask_width  (band-width  mask_band))
         (mask_height (band-height mask_band))
         (band2  (make-band width height 0.0))
         (foo    (vigra_fastnormalizedcrosscorrelation_c (band-data band) (band-data mask_band) (band-data band2) width height mask_width mask_height)))
    (case foo
      ((0) band2)
      ((1) (error "Error in vigracket.imgproc:fastnormalizedcrosscorrelation: Fast normalized cross-correlation of image failed!!"))
      ((2) (error "Error in vigracket.imgproc:fastnormalizedcrosscorrelation: Mask width and height need to be odd!!")))))

(define (fastnormalizedcrosscorrelation image mask)
  (map fastnormalizedcrosscorrelation-band image mask))

;###############################################################################
;###################           Local Maxima Extraction      ####################

(define vigra_localmaxima_c
  (get-ffi-obj 'vigra_localmaxima_c vigracket-dylib-path
               (_fun (img_vector1 img_vector2 width height) :: [img_vector1 : _cvector]
                     [img_vector2 : _cvector]
                     [width : _int]
                     [height : _int]
                     -> (res :  _int))))

(define (localmaxima-band band)
  (let* ((width  (band-width  band))
         (height (band-height band))
         (band2  (make-band width height 0.0))
         (foo   (vigra_localmaxima_c (band-data band) (band-data band2) width height)))
    (case foo
      ((0) band2)
      ((1) (error "Error in vigracket.imgproc:localmaxima: Finding local maxima of image failed!!")))))


(define (localmaxima image)
  (map localmaxima-band image))

;###############################################################################
;###################           Local Minima Extraction      ####################

(define vigra_localminima_c
  (get-ffi-obj 'vigra_localminima_c vigracket-dylib-path
               (_fun (img_vector1 img_vector2 width height) :: [img_vector1 : _cvector]
                     [img_vector2 : _cvector]
                     [width : _int]
                     [height : _int]
                     -> (res :  _int))))

(define (localminima-band band)
  (let* ((width  (band-width  band))
         (height (band-height band))
         (band2  (make-band width height 0.0))
         (foo   (vigra_localminima_c (band-data band) (band-data band2) width height)))
    (case foo
      ((0) band2)
      ((1) (error "Error in vigracket.imgproc:localminima: Finding local minima of image failed!!")))))


(define (localminima image)
  (map localminima-band image))

;###############################################################################
;###################         Resize image                   ####################

(define vigra_subimage_c
  (get-ffi-obj 'vigra_subimage_c vigracket-dylib-path
               (_fun (img_vector1 img_vector2  width height left upper right lower) :: [img_vector1 : _cvector]
                     [img_vector2 : _cvector]
                     [width : _int]
                     [height : _int]
                     [left : _int]
                     [upper : _int]
                     [right : _int]
                     [lower : _int]
                     -> (res :  _int))))

(define (subimage-band band left upper right lower)
  (let* ((width  (band-width  band))
         (height (band-height band))
         (cut_width (- right left))
         (cut_height (- lower upper))
         (band2  (make-band cut_width cut_height 0.0))
         (foo    (vigra_subimage_c (band-data band) (band-data band2) width height left upper right lower)))
    (case foo
      ((0) band2)
      ((1) (error "Error in vigracket.imgproc:subimage: Subimage creation failed!!"))
      ((2) (error "Error in vigracket.imgproc:subimage: Constraints not fullfilled: left < right, upper < lower, right - left <= width, lower - upper <= height")))))

(define (subimage image left upper right lower)
  (map (lambda (band) (subimage-band band left upper right lower)) image))

(provide
 resizeimage-band
           resizeimage
           rotateimage-band
           rotateimage
           affinewarpimage-band
           affinewarpimage
           reflectimage-band
           reflectimage
           fouriertransform-band
           fouriertransform
           fastcrosscorrelation-band
           fastcrosscorrelation
           fastnormalizedcrosscorrelation-band
           fastnormalizedcrosscorrelation
           localmaxima-band
           localmaxima
           localminima-band
           localminima
           subimage-band
           subimage)