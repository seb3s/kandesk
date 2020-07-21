-- *****************************************************************************
-- Copyright (c) 2020-2020 Sébastien SAINT-SEVIN
-- -----------------------------------------------------------------------------

-- Function: public.sp_duplicate_column(bigint, bigint)

-- DROP FUNCTION IF EXISTS public.sp_duplicate_column(bigint, bigint);

CREATE OR REPLACE FUNCTION sp_duplicate_column(v_column_id bigint, v_creator_id bigint)

RETURNS integer AS $$

DECLARE
    v_count integer;
    v_board_id bigint;
    v_last_pos integer;
    v_position integer;
    v_name text;
    v_descr text;
    v_new_column_id bigint;

BEGIN
    select name || ' ++', descr, position, board_id into v_name, v_descr, v_position, v_board_id
    from columns where id = v_column_id;

    select max(position) into v_last_pos from columns where board_id = v_board_id;

    insert into columns (name, descr, position, creator_id, board_id,
        inserted_at, updated_at, visibility)
    values (v_name, v_descr, v_last_pos + 1, v_creator_id, v_board_id, now(), now(), 'all')
    returning id into v_new_column_id;

    perform sp_move_column(v_board_id, v_last_pos + 1, v_position + 1);

    insert into tasks (name, descr, position, is_active, creator_id, column_id,
        due_date, inserted_at, updated_at, tags)
    select name, descr, position, is_active, creator_id, v_new_column_id,
        due_date, inserted_at, updated_at, tags
    from tasks where column_id = v_column_id;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$
LANGUAGE plpgsql;


-- *****************************************************************************
-- END OF FILE
-- -----------------------------------------------------------------------------