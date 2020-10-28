local t = ...

-- Filter the testcase XML with the VCS ID.
t:filterVcsId('../..', '../../netfield_label_tool.xml', 'netfield_label_tool.xml')

return true
