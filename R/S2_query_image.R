#' Prepare a list to query database for 'image'
#'
#' Implements the query options for 'images' described in the wiki.
#'
#' @param atmCorr  logical if TRUE only results for atmospherically corrected
#'   data are returned.
#' @param broken logical, TRUE if the granule is marked as broken
#'   (almost for sure you want to use FALSE, the default).
#' @param band chracter spectral band: B01/B02/B03/B04/B05/B06/B07/B08/B8A/B09/
#'   B10/B11/B12/all/SCL/LAI/albedo - see sentinel2 documentation.
#' @param cloudCovMin integer minimum cloud coverage from 0 to 100.
#' @param cloudCovMax integer maximum cloud coverage from 0 to 100.
#' @param dateMax character end date of format "YYYY-MM-DD".
#' @param dateMin character start date of format "YYYY-MM-DD".
#' @param geometry geometry which should intersect with granules. Can be a
#'   geoJSON geometry string (e.g. {"type":"Point","coordinates":[16.5,48.5]}),
#'   the path to a Point/Polygon shapefile, a SpatialPoints object or a
#'   SpatialPolygons object.
#' @param granule character ESA granule id.
#' @param granuleId integer internal metadata database granule id.
#' @param imageId integer internal metadata database image id.
#' @param orbitNo integer from 1 to 143.
#' @param owned logical when TRUE only already bought granules will be returned.
#' @param product chracter ESA product id.
#' @param productId integer internal metadata database product id.
#' @param resolution integer spatial resolution [m]: 60/20/10
#'   (resolution depends on the spectral band).
#' @param retGeometry logical should product geometry be included in the response?
#' @param utm character UTM zone, e.g. 33U, 01C.
#' @param dateSingle character date of format "YYYY-MM-DD", specifies a single
#'   date and will override \code{dateMin} and \code{dateMax}.
#' @param spatial logical, if TRUE the geometry column will contain
#'   SpatialPolygonsDataFrame objects instead of GeoJSON strings.
#'   Be aware that such conversion may take quite some time for large number of
#'   returned granules.
#' @param ... further arguments not implemented directly - see
#'   the \href{https://s2.boku.eodc.eu/wiki/#!image.md#GET_https://s2.boku.eodc.eu/image}{API doc}.
#' @return data.frame return of the database.
#' @export

S2_query_image <- function(atmCorr      = NULL,
                           band         = NULL,
                           broken       = FALSE,
                           cloudCovMin  = 0,
                           cloudCovMax  = 100,
                           dateMax      = Sys.Date(),
                           dateMin      = '2000-01-01',
                           geometry     = NULL,
                           granule      = NULL,
                           granuleId    = NULL,
                           imageId      = NULL,
                           orbitNo      = NULL,
                           owned        = FALSE,
                           product      = NULL,
                           productId    = NULL,
                           resolution   = NULL,
                           retGeometry  = FALSE,
                           utm          = NULL,
                           dateSingle   = NULL,
                           spatial      = FALSE,
                           ...){

  # check inputs ---------------------------------------------------------------
  if (isTRUE(spatial)) {
    retGeometry <- TRUE
  }

  if (!is.null(dateSingle)) {
    check_date(dateSingle)
    dateMin    <- dateSingle
    dateMax    <- dateSingle
    dateSingle <- NULL
  }

  if (check_date(dateMin) > check_date(dateMax)) {
    stop("'dateMin' (", dateMin, ") larger than 'dateMax' (", dateMax, ")")
  }

  # prepare json geometry ------------------------------------------------------
  if (!is.null(geometry)) {
    geometry <- roi_to_jgeom(geometry)
  }

  # make named query list ------------------------------------------------------
  query <- c(as.list(environment()), list(...))
  query <- query[!sapply(query, is.null)]

  # return query list ----------------------------------------------------------
  rtrn  <- S2_do_query(query = query, path = 'image')

  if (isTRUE(spatial)) {
    geometryJson = rtrn$geometry
    rtrn$geometry = vector('list', length(geometryJson))
    for (i in seq_along(geometryJson)) {
      rtrn$geometry[[i]] = rgdal::readOGR(geometryJson[i], 'OGRGeoJSON', verbose = FALSE)
    }
  }

  return(rtrn)
}

