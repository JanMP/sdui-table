import {Meteor} from 'meteor/meteor'
import {Mongo} from 'meteor/mongo'
import React, {useState, useEffect, useRef} from 'react'
import {meteorApply} from 'meteor/janmp:sdui-forms'
import EditableDataTable from './EditableDataTable'
import ErrorBoundary from './ErrorBoundary'
# import {Button, Icon, Modal, Table} from 'semantic-ui-react'
import {useTracker} from 'meteor/react-meteor-data'
import {toast} from 'react-toastify'
import {useCurrentUserIsInRole} from 'meteor/janmp:sdui-rolechecks'
import {getColumnsToExport} from 'meteor/janmp:sdui-backend'
import Papa from 'papaparse'
import {downloadAsFile} from 'meteor/janmp:sdui-backend'
# import {useDebounce} from '@react-hook/debounce'
import _ from 'lodash'

defaultQuery = {} # ensures equality between runs

export default MeteorDataAutoTable = (props) ->
  {
  sourceName, listSchemaBridge,
  usePubSub, rowsCollection, rowCountCollection
  query = defaultQuery
  perLoad
  canEdit = false
  formSchemaBridge
  canSearch = false
  canAdd = false
  onAdd
  canDelete = false
  deleteConfirmation = "Soll der Eintrag wirklich gelöscht werden?"
  onDelete
  canExport = false
  onExportTable
  onRowClick
  autoFormChildren
  formDisabled = false
  formReadOnly = false
  useSort = true
  getRowMethodName, getRowCountMethodName
  rowPublicationName, rowCountPublicationName
  submitMethodName, deleteMethodName, fetchEditorDataMethodName
  setValueMethodName
  exportRowsMethodName
  viewTableRole, editRole, exportTableRole
  } = props

  if usePubSub and not (rowsCollection? and rowCountCollection?)
    throw new Error 'usePubSub is true but rowsCollection or rowCountCollection not given'

  if sourceName?
    getRowMethodName ?= "#{sourceName}.getRows"
    getRowCountMethodName ?= "#{sourceName}.getCount"
    rowPublicationName ?= "#{sourceName}.rows"
    rowCountPublicationName ?= "#{sourceName}.count"
    submitMethodName ?= "#{sourceName}.submit"
    setValueMethodName ?= "#{sourceName}.setValue"
    fetchEditorDataMethodName ?= "#{sourceName}.fetchEditorData"
    deleteMethodName ?= "#{sourceName}.delete"
    exportRowsMethodName ?= "#{sourceName}.getExportRows"

  formSchemaBridge ?= listSchemaBridge

  if onRowClick and canEdit
    throw new Error 'both onRowClick and canEdit set to true'

  perLoad ?= 500
  onRowClick ?= ->

  resolveRef = useRef ->
  rejectRef = useRef ->

  [rows, setRows] = useState []
  [totalRowCount, setTotalRowCount] = useState 0
  [limit, setLimit] = useState perLoad

  [isLoading, setIsLoading] = useState false
  [loaderContent, setLoaderContent] = useState 'Lade Daten...'
  [loaderIndeterminate, setLoaderIndeterminate] = useState false

  [sortColumn, setSortColumn] = useState undefined
  [sortDirection, setSortDirection] = useState undefined
  
  [search, setSearch] = useState ''
  # [debouncedSearch, setDebouncedSearch] = useDebounce '', 1000

  mayEdit = useCurrentUserIsInRole editRole
  mayExport = (useCurrentUserIsInRole exportTableRole) and rows?.length

  if sortColumn? and sortDirection?
    sort = "#{sortColumn}": if sortDirection is 'ASC' then 1 else -1


  getRows = ->
    return if usePubSub
    setIsLoading true
    meteorApply
      method: getRowMethodName
      data: {search, query, sort, limit, skip}
    .then (returnedRows) ->
      setRows returnedRows
      setIsLoading false
    .catch (error) ->
      console.error error
      setIsLoading false

  getTotalRowCount = ->
    return if usePubSub
    meteorApply
      method: getRowCountMethodName
      data: {search, query}
    .then (result) ->
      setTotalRowCount result?[0]?.count or 0
    .catch console.error

  useEffect ->
    if query?
      getTotalRowCount()
    return
  , [search, query, sourceName]

  useEffect ->
    console.log [search, query, sortColumn, sortDirection, sourceName]
    setLimit perLoad
    return
  , [search, query, sortColumn, sortDirection, sourceName]

  # useEffect ->
  #   setDebouncedSearch search
  # , [search]

  skip = 0

  subLoading = useTracker ->
    return unless usePubSub
    handle = Meteor.subscribe rowPublicationName, {search, query, sort, skip, limit}
    not handle.ready()
  
  useEffect ->
    setIsLoading subLoading
  , [subLoading]
  
  countSubLoading = useTracker ->
    return unless usePubSub
    handle = Meteor.subscribe rowCountPublicationName, {query, search}
    not handle.ready()

  subRowCount = useTracker ->
    return unless usePubSub
    rowCountCollection.findOne({})?.count or 0
  
  useEffect ->
    setTotalRowCount subRowCount
  , [subRowCount]

  subRows = useTracker ->
    return unless usePubSub
    rowsCollection.find({}, {sort, limit}).fetch()

  useEffect ->
    unless _.isEqual subRows, rows
      setRows subRows
    return
  , [subRows]

  useEffect ->
    resolveRef.current() unless isLoading
  , [subLoading]

  loadMoreRows = ({startIndex, stopIndex}) ->
    console.log 'loadMoreRows', {startIndex, stopIndex}
    if stopIndex >= limit
      setLimit limit+perLoad
    new Promise (res, rej) ->
      resolveRef.current = res
      rejectRef.current = rej

  onChangeSort = (d) ->
    setSortColumn d.sortColumn
    setSortDirection d.sortDirection

  submit = (d) ->
    meteorApply
      method: submitMethodName
      data: d
    .then ->
      getRows()
    .catch (error) ->
      toast.error "#{error}"
      console.log error

  loadEditorData = ({id}) ->
    unless id?
      throw new Error 'loadEditorData: no id'
    meteorApply
      method: fetchEditorDataMethodName
      data: {id}
    .catch console.error

  onChangeSearch = (d) ->
    setSearch d

  onDelete ?= ({id}) ->    # setConfirmationModalOpen false
    meteorApply
      method: deleteMethodName
      data: {id}
    .then ->
      toast.success "Der Eintrag wurde gelöscht"
  
  onChangeField = ({_id, changeData}) ->
    meteorApply
      method: setValueMethodName
      data: {_id, changeData}
    .catch console.error
   
  if canExport
    onExportTable ?= ->
      meteorApply
        method: exportRowsMethodName
        data: {search, query, sort}
      .then (rows) ->
        toast.success "Exportdaten vom Server erhalten"
        Papa.unparse rows, columns: getColumnsToExport schema: listSchemaBridge.schema
      .then (csvString) ->
        downloadAsFile
          dataString: csvString
          fileName: title ? sourceName
      .catch (error) ->
        console.error error
        toast.error "Fehler (siehe console.log)"

  <ErrorBoundary>
    <EditableDataTable {{
      name: sourceName,
      listSchemaBridge, formSchemaBridge
      rows, totalRowCount, loadMoreRows, onRowClick,
      sortColumn, sortDirection, onChangeSort, useSort
      canSearch, search, onChangeSearch
      canAdd, onAdd
      canDelete, onDelete, deleteConfirmation
      canEdit, mayEdit, submit
      autoFormChildren, formDisabled, formReadOnly
      loadEditorData
      onChangeField,
      canExport, onExportTable
      mayExport
      isLoading, loaderContent, loaderIndeterminate
    }...} />
  </ErrorBoundary>

    