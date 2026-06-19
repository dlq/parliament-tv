"""Schedule and EPG scraper registry."""

from . import (
    brazil_tv_camara,
    cpac,
    new_zealand_parliament,
    ontario_calendar,
    quebec_webdiffusion,
)

SCRAPERS = {
    cpac.SOURCE["id"]: cpac,
    quebec_webdiffusion.SOURCE["id"]: quebec_webdiffusion,
    new_zealand_parliament.SOURCE["id"]: new_zealand_parliament,
    ontario_calendar.SOURCE["id"]: ontario_calendar,
    brazil_tv_camara.SOURCE["id"]: brazil_tv_camara,
}
