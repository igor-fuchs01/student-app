-- Student App — GET /subjects/:id as an RPC function.
--
-- The screen at /disciplinas/:subjectId stops depending on the mock: this is step
-- 1 of item 7 of docs/05-melhorias-futuras.md, whose remaining steps are content,
-- not plumbing. The tables it reads were added by
-- 20260922000000_subject_detail_content.sql.
--
-- Same rules as the other read endpoints in 20260916000200_api_read_functions.sql:
-- SECURITY DEFINER with search_path = '' and fully qualified names, the student
-- taken from auth.uid() and never from an argument, and the JSON built to match
-- the contract DTO exactly, so the frontend validates it with the same zod
-- schema the mock already uses.

-- SubjectDetail (§3.16, GET /subjects/:id). The counters and the preparation
-- come from the same views list_subjects reads, so the two endpoints can never
-- disagree about a subject.
create function public.get_subject(p_subject_id integer)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
  v_subject jsonb;
begin
  select jsonb_build_object(
    'id', s.id::text,
    'name', s.name,
    'shortLabel', s.short_label,
    'materialsCount', summary.materials_count,
    'questionsCount', summary.questions_count,
    'preparationPercent', coalesce(performance.preparation_percent, 0),
    -- Assuntos by number, the label the student reads (§3.17); subassuntos, key
    -- points and materials by the study order the team defined, which for
    -- materials is the order they were inserted in.
    'topics', (
      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'id', t.id::text,
            'number', t.number,
            'name', t.name,
            'description', t.description,
            'subtopics', (
              select coalesce(
                jsonb_agg(
                  jsonb_build_object(
                    'id', st.id::text,
                    'name', st.name,
                    'summary', st.summary,
                    'keyPoints', (
                      select coalesce(jsonb_agg(kp.text order by kp.order_index), '[]'::jsonb)
                      from public.subtopic_key_points kp
                      where kp.subtopic_id = st.id
                    ),
                    'materials', (
                      select coalesce(
                        jsonb_agg(
                          jsonb_build_object(
                            'id', m.id::text,
                            'title', m.title,
                            'fileUrl', m.file_url
                          )
                          order by m.id
                        ),
                        '[]'::jsonb
                      )
                      from public.materials m
                      where m.subtopic_id = st.id
                    )
                  )
                  order by st.order_index
                ),
                '[]'::jsonb
              )
              from public.subtopics st
              where st.topic_id = t.id
            )
          )
          order by t.number
        ),
        '[]'::jsonb
      )
      from public.topics t
      where t.subject_id = s.id
    )
  )
  into v_subject
  from public.subjects s
  join private.v_subject_summary summary on summary.subject_id = s.id
  left join private.v_student_subject_performance performance
    on performance.subject_id = s.id and performance.student_id = v_student_id
  where s.id = p_subject_id;

  if v_subject is null then
    perform private.raise_api_error(404, 'NOT_FOUND', 'Disciplina não encontrada.');
  end if;

  return v_subject;
end;
$$;

grant execute on all routines in schema public to authenticated;
