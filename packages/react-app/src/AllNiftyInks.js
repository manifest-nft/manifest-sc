import React, { useState, useEffect } from 'react'
import { Row, Col, Avatar, Empty, Space, Spin, Badge } from 'antd';
import { useEventListener } from "./hooks"
import { getFromIPFS } from "./helpers"

export default function NftyWallet(props) {

  //const [allInks, setAllInks] = useState()
  const [allInksArray, setAllInksArray] = useState([])
  let allInkView
  const [lastStreamCount, setLastStreamCount] = useState("0")

  let inkCreations = useEventListener(props.readContracts,'NFTINK',"newInk",props.localProvider, 1)
  let likes

  useEffect(()=>{

      if(props.tab === props.thisTab && props.readContracts && inkCreations && props.totalInks && inkCreations.length) {
      if(inkCreations.length.toString() == props.totalInks.toString() &&
        props.totalInks.toString() !== lastStreamCount
      ) {
        let allInks = new Array(Math.min(12, props.totalInks.toString())).fill({})
        setLastStreamCount(props.totalInks.toString())

        console.log(props.tab, props.totalInks, inkCreations, lastStreamCount)

        const getInkImages = async (e) => {
          const jsonContent = await getFromIPFS(e['jsonUrl'], props.ipfsConfig)
          const inkJson = JSON.parse(jsonContent)
          const inkImageHash = inkJson.image.split('/').pop()
          const imageContent = await getFromIPFS(inkImageHash, props.ipfsConfig)
          const inkImageURI = 'data:image/png;base64,' + imageContent.toString('base64')
          if (props.readContracts['Liker']) {
            let niftyAddress = props.readContracts['NFTINK']['address']
            likes = await props.readContracts['Liker']['getLikesByTarget'](niftyAddress, e['id'])
          }
          return Object.assign({image: inkImageURI, name: inkJson.name, url: inkJson.drawing, likes: likes.toString()}, e);
        }

        const loadStream = async (e) => {
          if(inkCreations) {

            let mostRecentInks = inkCreations.slice(-12).reverse()
            for(var i = 0; i < 12; i++){
               let inkDetails = await getInkImages(mostRecentInks[i])
               allInks[i] = inkDetails
               setAllInksArray(allInks)
            }
          }
        }
        loadStream()

      }
    }
  },[props.tab, props.totalInks])

       if(allInksArray) {
         allInkView = (
      <Row>
        {allInksArray.map(item =>
        <Col span={8}>{item['image']?<Badge style={{ backgroundColor: '#2db7f5' }} count={item['likes']}><img src={item['image']} alt={item['name']} onClick={() => props.showInk(item['url'])} width='120' height='120'/></Badge>:<Avatar size={120} style={{ backgroundColor: '#FFFFFF' }} icon={<Spin style={{opacity:0.25}} size="large" />} />}</Col>
      )}
      </Row>
    )
    } else {
      allInkView = (<Empty
        description={
          <span>
          No inks...
            </span>
          }
          />
        )
    }

    return allInkView

        }