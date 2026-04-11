from user_agents import parse as parse_ua

from prometheus_client import Counter, Histogram, Gauge


# Request metrics
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"],
)

REQUEST_DURATION = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "endpoint"],
    buckets=[0.01, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0],
)

# Visitor metrics
VISITOR_BY_COUNTRY = Counter(
    "visitor_country_total",
    "Visitors by country code",
    ["country"],
)

VISITOR_BY_PLATFORM = Counter(
    "visitor_platform_total",
    "Visitors by platform/OS",
    ["platform"],
)

VISITOR_BY_BROWSER = Counter(
    "visitor_browser_total",
    "Visitors by browser",
    ["browser"],
)

VISITOR_BY_DEVICE = Counter(
    "visitor_device_total",
    "Visitors by device type",
    ["device_type"],
)

VISITOR_BY_PATH = Counter(
    "visitor_page_total",
    "Page views by path",
    ["path"],
)

UNIQUE_VISITORS = Gauge(
    "unique_visitors_current",
    "Approximate unique visitor IPs seen",
)

# Track unique IPs (in-memory, resets on pod restart)
_seen_ips: set = set()


def track_visitor(
    ip: str | None,
    user_agent_str: str | None,
    path: str,
    country: str | None = None,
):
    """Track a visitor hit with all dimensions."""
    # Country
    VISITOR_BY_COUNTRY.labels(
        country=country or "unknown"
    ).inc()

    # Parse user agent
    if user_agent_str:
        ua = parse_ua(user_agent_str)
        VISITOR_BY_PLATFORM.labels(
            platform=ua.os.family or "unknown"
        ).inc()
        VISITOR_BY_BROWSER.labels(
            browser=ua.browser.family or "unknown"
        ).inc()

        if ua.is_mobile:
            device = "mobile"
        elif ua.is_tablet:
            device = "tablet"
        elif ua.is_bot:
            device = "bot"
        else:
            device = "desktop"
        VISITOR_BY_DEVICE.labels(device_type=device).inc()
    else:
        VISITOR_BY_PLATFORM.labels(platform="unknown").inc()
        VISITOR_BY_BROWSER.labels(browser="unknown").inc()
        VISITOR_BY_DEVICE.labels(device_type="unknown").inc()

    # Page
    VISITOR_BY_PATH.labels(path=path).inc()

    # Unique IPs
    if ip:
        _seen_ips.add(ip)
        UNIQUE_VISITORS.set(len(_seen_ips))
