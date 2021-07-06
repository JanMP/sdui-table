import React from 'react'
import DynamicTableField from './DynamicTableField'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {faCheck, faTimes} from '@fortawesome/free-solid-svg-icons'
import _ from 'lodash'

style =
  padding: "4px 0"

export default AutoTableAutoField = ({row, columnKey, schemaBridge, onChangeField, measure, mayEdit}) ->
  fieldSchema = schemaBridge.schema._schema[columnKey]
  inner =
    if (component = fieldSchema.autotable?.component)?
      try
        component {row, columnKey, schemaBridge, onChangeField, measure, mayEdit}
      catch error
        console.error error
        console.log 'the previous error happened in AutotableAutoField with params', {row, columnKey, schemaBridge, component}
    else if fieldSchema.autotable?.editable
      <DynamicTableField {{row, columnKey, schemaBridge, onChangeField, mayEdit}...}/>
    else if fieldSchema.autotable?.markup
      <div dangerouslySetInnerHTML={__html: row[columnKey]} />
    else
      switch fieldType = fieldSchema.type.definitions[0].type
        when Date
          <span>{row[columnKey]?.toLocaleString()}</span>
        when Boolean
          if row[columnKey] then <FontAwesomeIcon icon={faCheck}/> else <FontAwesomeIcon icon={faTimes}/>
        when Array
          row[columnKey]?.map (entry, i) ->
            if _.isObject entry
              <pre>{JSON.stringify row[columnKey], null, 2}</pre>
            else
              <div key={i} style={whiteSpace: 'normal', marginBottom: '.2rem'}>{entry}</div>
        else
          if _.isObject row[columnKey] or _.isArray row[columnKey]
            <pre>{JSON.stringify row[columnKey], null, 2}</pre>
          else
            <div style={whiteSpace: 'normal'}>{row[columnKey]}</div>

  <div style={style}>{inner}</div>
    