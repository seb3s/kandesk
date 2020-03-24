-- *****************************************************************************
-- Copyright (c) 2020-2020 Sébastien SAINT-SEVIN
-- -----------------------------------------------------------------------------

-- Function: public.sp_delete_board(bigint)

-- DROP FUNCTION public.sp_delete_board(bigint);

CREATE OR REPLACE FUNCTION sp_delete_board(v_board_id bigint)

RETURNS integer AS $$

DECLARE
    v_count integer;

BEGIN
    delete from tasks
    where column_id in (select id from columns where board_id = v_board_id);

    delete from columns
    where board_id = v_board_id;

    delete from boards
    where id = v_board_id;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$
LANGUAGE plpgsql;


-- Function: public.sp_delete_column(bigint)

-- DROP FUNCTION public.sp_delete_column(bigint);

CREATE OR REPLACE FUNCTION sp_delete_column(v_column_id bigint)

RETURNS integer AS $$

DECLARE
    v_count integer;
    v_board_id bigint;
    v_position integer;

BEGIN
    delete from tasks
    where column_id = v_column_id;

    delete from columns
    where id = v_column_id
    returning board_id, position into v_board_id, v_position;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    update columns
    set position = position - 1
    where board_id = v_board_id and position > v_position;

    RETURN v_count;
END;
$$
LANGUAGE plpgsql;


-- Function: public.sp_move_column(bigint, integer, integer)

-- DROP FUNCTION public.sp_move_column(bigint, integer, integer);

CREATE OR REPLACE FUNCTION sp_move_column(
    v_board_id bigint,
    v_old_pos integer,
    v_new_pos integer)

RETURNS void AS $$

DECLARE
    v_inc integer;
    v_min_pos integer;
    v_max_pos integer;

BEGIN
    if v_old_pos = v_new_pos then RETURN; end if;
    if v_old_pos > v_new_pos then
        v_inc = 1;
        v_min_pos = v_new_pos;
        v_max_pos = v_old_pos;
    else
        v_inc = -1;
        v_min_pos = v_old_pos;
        v_max_pos = v_new_pos;
    end if;

    update columns
    set position = case
        when position = v_old_pos then v_new_pos
        else position + v_inc
        end
    where
        board_id = v_board_id and
        position between v_min_pos and v_max_pos;

    RETURN;
END;
$$
LANGUAGE plpgsql;


-- Function: public.sp_delete_task(bigint)

-- DROP FUNCTION public.sp_delete_task(bigint);

CREATE OR REPLACE FUNCTION sp_delete_task(v_task_id bigint)

RETURNS integer AS $$

DECLARE
    v_count integer;
    v_column_id bigint;
    v_position integer;

BEGIN
    delete from tasks
    where id = v_task_id
    returning column_id, position into v_column_id, v_position;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    update tasks
    set position = position - 1
    where column_id = v_column_id and position > v_position;

    RETURN v_count;
END;
$$
LANGUAGE plpgsql;


-- Function: public.sp_move_task(bigint, bigint, bigint, integer, integer)

-- DROP FUNCTION public.sp_move_task(bigint, bigint, bigint, integer, integer);

CREATE OR REPLACE FUNCTION sp_move_task(
    v_task_id bigint,
    v_old_column_id bigint,
    v_new_column_id bigint,
    v_old_pos integer,
    v_new_pos integer)

RETURNS void AS $$

DECLARE
    v_inc integer;
    v_min_pos integer;
    v_max_pos integer;

BEGIN
    if v_old_column_id = v_new_column_id then
        if v_old_pos = v_new_pos then RETURN; end if;
        if v_old_pos > v_new_pos then
            v_inc = 1;
            v_min_pos = v_new_pos;
            v_max_pos = v_old_pos;
        else
            v_inc = -1;
            v_min_pos = v_old_pos;
            v_max_pos = v_new_pos;
        end if;

        update tasks
        set position = case
            when position = v_old_pos then v_new_pos
            else position + v_inc
            end
        where
            column_id = v_new_column_id and
            position between v_min_pos and v_max_pos;
    else
        update tasks
        set position = position - 1
        where column_id = v_old_column_id and position > v_old_pos;

        update tasks
        set position = position + 1
        where column_id = v_new_column_id and position >= v_new_pos;

        update tasks
        set column_id = v_new_column_id,
            position = v_new_pos
        where id = v_task_id;
    end if;

    RETURN;
END;
$$
LANGUAGE plpgsql;


-- *****************************************************************************
-- END OF FILE
-- -----------------------------------------------------------------------------