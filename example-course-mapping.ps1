Function BuildMappingHash($mappingdata)
{
    $MappingHash = @{}
    foreach ($map in $mappingdata) {
        $MappingHash.Set_Item($map.key,$map.template_course_id)
    }
    return $MappingHash
}

Function GetTemplateCourseId($courseid, $mappinghash)
{
    $TemplateId = "DEFAULT-TEMPLATE-COURSE_ID"
    #key assumes courseids are of the form 201920-1-CHE1141-M-2584
    $key = ($courseid -split "-")[1..3] -join "-"
    if($mappinghash.ContainsKey($key)) { $TemplateID = $mappinghash.Get_Item($key) }
    return $TemplateID
}

$maphash = BuildMappingHash $(import-csv .\example-course-mapping.csv)

# to get one template
# $courseid = "201920-1-CHE1141-M-2584"
# $template = GetTemplateCourseId $courseid $maphash

# for a previously prepared feedfile
$orgfeed = import-csv -Delimiter "|" .\example-course-feed.txt
$newfeed = $orgfeed | select Course_Name, Data_Source_Key, Row_Status, Course_ID, @{Name='template_course_key'; Expression={GetTemplateCourseId $_.Course_ID $maphash }}

$newfeed |convertto-csv -Delimiter "|" -notype |% {$_ -replace '"'}  | out-file -Encoding utf8 -force ".\updated-feed-file.txt"
