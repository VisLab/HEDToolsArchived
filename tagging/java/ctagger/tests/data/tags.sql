CREATE TABLE tags
(
  tag_uuid uuid NOT NULL,
  tag_pathname character varying,
  tag_parent_uuid uuid REFERENCES tags on delete cascade,
  tag_description character varying,
  tag_count integer,
  tag_creation timestamp with time zone,
  tag_last_modified timestamp with time zone,
  tag_owner_email character varying,
  CONSTRAINT tag_pk PRIMARY KEY (tag_uuid)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE tag_attributes
(
  tag_attribute_uuid uuid NOT NULL,
  tag_attribute_tag_uuid uuid REFERENCES tags on delete cascade,
  tag_attribute_name character varying,
  tag_attribute_value character varying,
  CONSTRAINT tag_attributes_pk PRIMARY KEY (tag_attribute_uuid)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE tag_comments
(
  tag_comment_uuid uuid NOT NULL,
  tag_comment_tag_uuid uuid REFERENCES tags on delete cascade,
  tag_comment_date timestamp with time zone,
  tag_comment_author character varying,
  tag_comment_text character varying,
  CONSTRAINT tag_comments_pk PRIMARY KEY (tag_comment_uuid)
)
WITH (
  OIDS=FALSE
);