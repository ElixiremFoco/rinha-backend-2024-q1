CREATE TABLE customers (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	max_limit INTEGER NOT NULL,
	balance INTEGER CHECK (balance >= -max_limit) NOT NULL
);

CREATE TABLE projection_versions (
	projection_name TEXT PRIMARY KEY,
	last_seen_event_number BIGINT,
	inserted_at TIMESTAMP DEFAULT now() NOT NULL,
	updated_at TIMESTAMP DEFAULT now() NOT NULL
);

CREATE TABLE transactions(
  id SERIAL PRIMARY KEY,
  value INTEGER NOT NULL,
  customer_id INTEGER REFERENCES customers(id),
  type VARCHAR(1) CHECK (type IN ('c', 'd')) NOT NULL,
  description VARCHAR(10) NOT NULL,
  created_at TIMESTAMP DEFAULT now() NOT NULL
);

DO $$
BEGIN
	INSERT INTO customers (name, max_limit, balance)
	VALUES
		('o barato sai caro', 1000 * 100, 0),
		('zan corp ltda', 800 * 100, 0),
		('les cruders', 10000 * 100, 0),
		('padaria joia de cocaia', 100000 * 100, 0),
		('kid mais', 5000 * 100, 0);
END;
$$;
