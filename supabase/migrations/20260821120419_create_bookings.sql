-- Bookings table for Bharath Convention Hall
-- No auth required — open access for the hall owner's app

CREATE TABLE IF NOT EXISTS public.bookings (
    id TEXT PRIMARY KEY,
    client_name TEXT NOT NULL,
    phone TEXT NOT NULL DEFAULT '',
    event_type TEXT NOT NULL DEFAULT 'Wedding',
    event_date DATE NOT NULL,
    function_time TEXT NOT NULL DEFAULT 'Day',
    guest_count INTEGER NOT NULL DEFAULT 0,
    total_amount DOUBLE PRECISION NOT NULL DEFAULT 0,
    advance_paid DOUBLE PRECISION NOT NULL DEFAULT 0,
    booking_status TEXT NOT NULL DEFAULT 'confirmed',
    notes TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Index for fast date lookups
CREATE INDEX IF NOT EXISTS idx_bookings_event_date ON public.bookings(event_date);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(booking_status);

-- Enable RLS
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Open access policy (no auth — single-owner app)
DROP POLICY IF EXISTS "open_access_bookings" ON public.bookings;
CREATE POLICY "open_access_bookings"
ON public.bookings
FOR ALL
TO public
USING (true)
WITH CHECK (true);

-- Auto-update updated_at on row changes
CREATE OR REPLACE FUNCTION public.update_bookings_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS bookings_updated_at ON public.bookings;
CREATE TRIGGER bookings_updated_at
    BEFORE UPDATE ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.update_bookings_updated_at();
