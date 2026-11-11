-- ==============================================================================
-- SECTION 12: RECURSIVE COMMON TABLE EXPRESSIONS (Questions 86 - 90)
-- ==============================================================================

-- 86. Display category hierarchy (Full breadcrumb path).
WITH RECURSIVE CategoryHierarchy AS (
    -- Anchor Member: Root categories (no parent)
    SELECT 
        category_id,
        category_name,
        parent_category_id,
        CAST(category_name AS VARCHAR(1000)) AS breadcrumb_path,
        1 AS depth_level
    FROM CATEGORIES
    WHERE parent_category_id IS NULL

    UNION ALL

    -- Recursive Member: Sub-categories
    SELECT 
        c.category_id,
        c.category_name,
        c.parent_category_id,
        CAST(ch.breadcrumb_path || ' > ' || c.category_name AS VARCHAR(1000)),
        ch.depth_level + 1
    FROM CATEGORIES c
    JOIN CategoryHierarchy ch ON c.parent_category_id = ch.category_id
)
SELECT 
    category_id,
    breadcrumb_path,
    depth_level
FROM CategoryHierarchy
ORDER BY breadcrumb_path;

-- 87. Display sub-category tree (Visual indentation).
WITH RECURSIVE CategoryTree AS (
    SELECT 
        category_id,
        category_name,
        parent_category_id,
        0 AS tree_level,
        CAST(category_name AS VARCHAR(255)) AS indented_name
    FROM CATEGORIES
    WHERE parent_category_id IS NULL

    UNION ALL

    SELECT 
        c.category_id,
        c.category_name,
        c.parent_category_id,
        ct.tree_level + 1,
        CAST(REPEAT('    ', ct.tree_level + 1) || '|-- ' || c.category_name AS VARCHAR(255))
    FROM CATEGORIES c
    JOIN CategoryTree ct ON c.parent_category_id = ct.category_id
)
SELECT 
    category_id,
    indented_name AS category_tree_view,
    tree_level
FROM CategoryTree
ORDER BY category_id;

-- 88. Display employee reporting hierarchy.
WITH RECURSIVE EmployeeHierarchy AS (
    -- Anchor: CEO / Top executive without manager
    SELECT 
        employee_id,
        employee_name,
        manager_id,
        designation,
        salary,
        CAST(employee_name AS VARCHAR(1000)) AS management_chain,
        1 AS org_level
    FROM EMPLOYEES
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: Direct & indirect reports
    SELECT 
        e.employee_id,
        e.employee_name,
        e.manager_id,
        e.designation,
        e.salary,
        CAST(eh.management_chain || ' -> ' || e.employee_name AS VARCHAR(1000)),
        eh.org_level + 1
    FROM EMPLOYEES e
    JOIN EmployeeHierarchy eh ON e.manager_id = eh.employee_id
)
SELECT 
    employee_id,
    employee_name,
    designation,
    org_level,
    management_chain
FROM EmployeeHierarchy
ORDER BY org_level ASC, employee_id ASC;

-- 89. Find all managers and all employees under them (Transitive Closure).
WITH RECURSIVE SubordinateTree AS (
    -- Anchor: Direct reports for each manager
    SELECT 
        manager_id,
        employee_id AS subordinate_id,
        1 AS distance
    FROM EMPLOYEES
    WHERE manager_id IS NOT NULL

    UNION ALL

    -- Recursive: Indirect reports
    SELECT 
        st.manager_id,
        e.employee_id AS subordinate_id,
        st.distance + 1
    FROM SubordinateTree st
    JOIN EMPLOYEES e ON e.manager_id = st.subordinate_id
)
SELECT 
    m.employee_id AS manager_id,
    m.employee_name AS manager_name,
    m.designation AS manager_designation,
    COUNT(st.subordinate_id) AS total_subordinates_count
FROM EMPLOYEES m
JOIN SubordinateTree st ON m.employee_id = st.manager_id
GROUP BY m.employee_id, m.employee_name, m.designation
ORDER BY total_subordinates_count DESC;

-- 90. Generate category depth levels.
WITH RECURSIVE CategoryDepth AS (
    SELECT 
        category_id,
        category_name,
        parent_category_id,
        0 AS depth_level
    FROM CATEGORIES
    WHERE parent_category_id IS NULL

    UNION ALL

    SELECT 
        c.category_id,
        c.category_name,
        c.parent_category_id,
        cd.depth_level + 1
    FROM CATEGORIES c
    JOIN CategoryDepth cd ON c.parent_category_id = cd.category_id
)
SELECT 
    depth_level,
    COUNT(*) AS categories_at_depth,
    STRING_AGG(category_name, ', ') AS categories_list
FROM CategoryDepth
GROUP BY depth_level
ORDER BY depth_level ASC;
